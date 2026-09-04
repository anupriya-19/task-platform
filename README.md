# TaskFlow V1

Admin-controlled task + part-time assignment dashboard.

## V1 flow
Task → Part-time Requirement → Person → Assignment → Completion → Payment

## Stack
- Vite + React-style single-page UI (vanilla JS components)
- Supabase PostgreSQL
- Responsive CSS

## Run
1. `npm install`
2. Copy `.env.example` to `.env` and add your Supabase URL + anon key.
3. Run `supabase/schema.sql` in Supabase SQL Editor.
4. `npm run dev`

If Supabase environment variables are missing, the UI runs in local demo mode for navigation/forms; data is not persistent across refreshes.

## Important production step
The SQL includes permissive development RLS policies so V1 can be tested quickly. Before public deployment, enable Supabase Auth and replace them with authenticated admin/staff policies. Never expose a Supabase service-role key in frontend code.
