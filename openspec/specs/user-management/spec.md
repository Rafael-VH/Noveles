# Spec: User Management (Admin)

> **Type**: Full spec — new capability
> **Change**: `admin-panel-improvements`

## Purpose

Provide admin-only read-only listing of all registered user profiles. Admins can view user ID, email, display name, and role. No editing or role changes — strictly view-only.

## Requirements

### REQ-UM-1: User list
**Given** the admin navigates to the user management screen  
**When** the screen loads  
**Then** all profiles from the `profiles` table are displayed  
**And** each row shows id, email, display_name, role

### REQ-UM-2: Graceful missing fields
**Given** a profile has a null `display_name`  
**When** the list renders  
**Then** the email is shown as fallback display text  
**And** no crash or broken UI occurs

### REQ-UM-3: No edit capability
**Given** the admin views a user row  
**When** they tap on it  
**Then** no edit screen or action is triggered (no-op or tap feedback only)

### REQ-UM-4: Error handling
**Given** the profiles query fails  
**When** the screen loads  
**Then** an error message is displayed with a retry button
