import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'jsr:@supabase/supabase-js@2';

interface LabelRule {
  id: number;
  label_id: number;
  rule_type: 'new_release' | 'most_read' | 'most_popular' | 'most_favorited';
  params: Record<string, number>;
}

serve(async (req) => {
  // Only allow POST
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 });
  }

  const authHeader = req.headers.get('Authorization');
  if (!authHeader) {
    return new Response('Unauthorized', { status: 401 });
  }

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
  );

  try {
    // Fetch all active rules
    const { data: rules, error: rulesError } = await supabase
      .from('label_rules')
      .select('*');

    if (rulesError) throw rulesError;
    if (!rules || rules.length === 0) {
      return new Response(JSON.stringify({ synced: 0, message: 'No rules to process' }), {
        headers: { 'Content-Type': 'application/json' },
      });
    }

    const results: { rule_id: number; label_id: number; assigned: number; removed: number }[] = [];

    for (const rule of rules as LabelRule[]) {
      const { label_id, rule_type, params } = rule;
      let bookIds: number[] = [];

      switch (rule_type) {
        case 'new_release': {
          const days = params.days ?? 30;
          const { data } = await supabase
            .from('books')
            .select('id')
            .gte('created_at', `now() - interval '${days} days'`);
          bookIds = (data ?? []).map((b: { id: number }) => b.id);
          break;
        }

        case 'most_read': {
          const limit = params.limit ?? 10;
          const days = params.days ?? 30;
          const { data } = await supabase
            .from('book_views')
            .select('book_id')
            .gte('viewed_at', `now() - interval '${days} days'`);
          // Count and sort in memory
          const counts = new Map<number, number>();
          for (const row of data ?? []) {
            counts.set(row.book_id, (counts.get(row.book_id) ?? 0) + 1);
          }
          bookIds = [...counts.entries()]
            .sort((a, b) => b[1] - a[1])
            .slice(0, limit)
            .map(([id]) => id);
          break;
        }

        case 'most_popular': {
          const limit = params.limit ?? 10;
          const { data } = await supabase
            .from('books')
            .select('id, took_count, chapter_count')
            .order('took_count', { ascending: false })
            .limit(limit * 2); // overfetch for in-memory sort
          bookIds = (data ?? [])
            .sort((a: { took_count: number; chapter_count: number }, b: { took_count: number; chapter_count: number }) =>
              (b.took_count + b.chapter_count) - (a.took_count + a.chapter_count),
            )
            .slice(0, limit)
            .map((b: { id: number }) => b.id);
          break;
        }

        case 'most_favorited': {
          const limit = params.limit ?? 10;
          const { data } = await supabase
            .from('user_favorites')
            .select('book_id');
          const counts = new Map<number, number>();
          for (const row of data ?? []) {
            counts.set(row.book_id, (counts.get(row.book_id) ?? 0) + 1);
          }
          bookIds = [...counts.entries()]
            .sort((a, b) => b[1] - a[1])
            .slice(0, limit)
            .map(([id]) => id);
          break;
        }
      }

      // Get current assignments for this label
      const { data: currentData } = await supabase
        .from('books_labels')
        .select('book_id')
        .eq('label_id', label_id);

      const currentIds = new Set((currentData ?? []).map((r: { book_id: number }) => r.book_id));
      const targetIds = new Set(bookIds);

      // Books to add (in target but not in current)
      const toAdd = bookIds.filter((id) => !currentIds.has(id));
      // Books to remove (in current but not in target)
      const toRemove = [...currentIds].filter((id) => !targetIds.has(id));

      // Apply changes
      if (toAdd.length > 0) {
        const { error: insertError } = await supabase.from('books_labels').upsert(
          toAdd.map((book_id) => ({ book_id, label_id })),
          { onConflict: 'book_id, label_id', ignoreDuplicates: true },
        );
        if (insertError) console.error(`Insert error for rule ${rule.id}:`, insertError);
      }

      if (toRemove.length > 0) {
        const { error: deleteError } = await supabase
          .from('books_labels')
          .delete()
          .eq('label_id', label_id)
          .in('book_id', toRemove);
        if (deleteError) console.error(`Delete error for rule ${rule.id}:`, deleteError);
      }

      results.push({ rule_id: rule.id, label_id, assigned: toAdd.length, removed: toRemove.length });
    }

    return new Response(JSON.stringify({ synced: results.length, results }), {
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (error) {
    console.error('Sync error:', error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
});
