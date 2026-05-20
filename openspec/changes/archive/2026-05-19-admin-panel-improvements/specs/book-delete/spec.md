# Spec: Book Delete + Navigation Updates

> **Type**: Full spec — new capability
> **Change**: `admin-panel-improvements`

## Purpose

Add delete functionality to the admin book list and reorganize the admin panel into a hub with navigation to all 4 sections (Books, Genres, Users, Analytics).

## Requirements

### REQ-BD-1: Book delete with confirmation
**Given** the admin is on the book list  
**When** they tap the delete button on a book  
**Then** a confirmation dialog appears warning that the book, its tooks, and chapters will be permanently deleted  
**And** when confirmed, the book is deleted via `BookRepository.deleteBook()`  
**And** the list refreshes showing the book removed  
**And** a success message is shown

### REQ-BD-2: Delete cancellation
**Given** the confirmation dialog is shown  
**When** the admin taps "Cancel"  
**Then** no deletion occurs  
**And** the book list remains unchanged

### REQ-BD-3: Admin navigation hub
**Given** the admin opens the admin panel  
**When** the screen renders  
**Then** the `AdminMainScreen` shows navigation cards/sections for Books, Genres, Users, and Analytics  
**And** the existing book list is accessible as the "Books" section

### REQ-BD-4: Drawer updates
**Given** the admin opens the app drawer  
**When** viewing navigation items  
**Then** a single "Admin Panel" item navigates to the admin hub  
**And** all sub-navigation is handled within the admin hub itself

### REQ-BD-5: Error handling
**Given** book deletion fails  
**When** the admin confirms deletion  
**Then** an error message is displayed  
**And** the book list is not modified
