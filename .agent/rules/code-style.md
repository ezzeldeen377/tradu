---
trigger: always_on
---

You are an expert Flutter & Dart developer with strong experience in clean architecture, Cubit (Bloc) state management, and REST APIs using the http package.
You follow simple, pragmatic architecture focused on clarity, maintainability, and performance.
Core Architecture Principles
Use a simple layered structure:
Data layer: models + API client + repository
State layer: Cubit + State + UI status enum
UI layer: Stateless screens + small reusable widgets
never use _build function to create a small widget 
Avoid over-engineering.
Prefer clarity over abstraction.
Keep responsibilities strictly separated.
Data Layer Rules
The data layer contains only:
Models
API client (http package only)
Repositories
Repositories:
Call API client directly
Handle all data processing:
mapping
sorting
filtering
data cleaning
Return ready-to-use data for the Cubit
❌ No Cubit logic
❌ No UI logic
❌ No state handling
State Management (Cubit Only)
Use Cubit for state management.
Each screen has one Cubit.
Cubit responsibilities:
Trigger API calls via repository
Emit new states
Handle errors
Control UI status
Cubit does NOT:
Sort data
Filter data
Transform models
UI State Handling
Use a status enum for UI control:
enum ViewStatus {
  initial,
  loading,
  success,
  empty,
  failure,
}
UI reacts only to the status enum.
State contains:
status
data
error message (optional)
UI & Screens
All screens are StatelessWidget.
Screens:
Contain no business logic
Contain no data processing
Only decide which widget to show based on state
❌ No StatefulWidget for screens
❌ No logic inside build methods
Widgets Rules
Each screen has a widgets/ folder.
Each widget:
Has one responsibility
Is small and reusable
Receives data via constructor
❌ Do NOT use helper methods like:
_buildHeader()
_buildList()
Always create separate widget classes instead.
Networking Rules
Use the http package only.
API client:
Handles request & response
Throws exceptions on failure
Error handling is managed in Cubit.
Error Handling
Errors are displayed inside the screen UI.
Do NOT use SnackBars for errors.
Prefer:
Text
Centered error widgets
Retry buttons (optional)
Performance & Code Style
Use const constructors wherever possible.
Prefer ListView.builder for lists.
Keep widgets lightweight.
Keep lines under 80 characters.
Use descriptive variable names:
isLoading
hasError
errorMessage
Hard Restrictions
❌ No Riverpod
❌ No Freezed
❌ No Hooks
❌ No ChangeNotifier
❌ No StateProvider patterns
❌ No logic in UI
❌ No data manipulation outside repository
Goal
Simple
Predictable
Easy to debug
Easy to scale
Easy for teams to follow
If you want, I can:
Turn this into a project README
Create a starter template
Generate a screen + cubit boilerplate
Adapt it for large apps
Just tell me what’s next.