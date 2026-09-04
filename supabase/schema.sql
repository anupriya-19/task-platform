create extension if not exists pgcrypto;

create table if not exists public.people (
 id uuid primary key default gen_random_uuid(),
 name text not null check (char_length(name) between 1 and 100),
 phone text,
 email text,
 profile_photo text,
 location text,
 latitude numeric,
 longitude numeric,
 skills text[] default '{}',
 availability text,
 status text not null default 'Available' check (status in ('Available','Busy','Inactive','Blocked')),
 payment_method text,
 payment_details text,
 notes text,
 created_at timestamptz not null default now()
);

create table if not exists public.tasks (
 id uuid primary key default gen_random_uuid(),
 task_number text unique not null,
 title text not null check (char_length(title) between 1 and 120),
 description text not null check (char_length(description) <= 2000),
 category_id uuid,
 priority text not null default 'Normal' check (priority in ('Low','Normal','High','Urgent')),
 location_name text,
 latitude numeric,
 longitude numeric,
 online_or_offline text not null default 'Offline' check (online_or_offline in ('Online','Offline','Hybrid')),
 start_date date,
 deadline date not null,
 estimated_hours numeric(8,2) default 0 check (estimated_hours >= 0),
 budget numeric(12,2) not null default 0 check (budget >= 0),
 status text not null default 'Draft' check (status in ('Draft','Open','Assigned','In Progress','Completed','On Hold','Cancelled')),
 created_by uuid,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);

create table if not exists public.part_time_requirements (
 id uuid primary key default gen_random_uuid(),
 task_id uuid not null references public.tasks(id) on delete cascade,
 title text not null,
 people_required integer not null default 1 check (people_required > 0),
 skills_required text[] default '{}',
 location text,
 max_distance_km numeric(8,2),
 start_date date,
 end_date date,
 start_time time,
 end_time time,
 payment_type text not null default 'Per task' check (payment_type in ('Per task','Per hour','Per day')),
 payment_amount numeric(12,2) not null default 0 check (payment_amount >= 0),
 experience_required text,
 requirements text,
 status text not null default 'Open' check (status in ('Open','Filled','Closed','Cancelled')),
 created_at timestamptz not null default now()
);

create table if not exists public.assignments (
 id uuid primary key default gen_random_uuid(),
 task_id uuid not null references public.tasks(id) on delete cascade,
 requirement_id uuid references public.part_time_requirements(id) on delete set null,
 person_id uuid not null references public.people(id) on delete restrict,
 assigned_by uuid,
 assigned_at timestamptz not null default now(),
 accepted_at timestamptz,
 started_at timestamptz,
 completed_at timestamptz,
 status text not null default 'Pending' check (status in ('Pending','Accepted','Rejected','In Progress','Completed','Cancelled')),
 agreed_payment numeric(12,2) not null default 0 check (agreed_payment >= 0),
 notes text
);

create table if not exists public.payments (
 id uuid primary key default gen_random_uuid(),
 assignment_id uuid not null references public.assignments(id) on delete cascade,
 person_id uuid not null references public.people(id) on delete restrict,
 amount numeric(12,2) not null check (amount >= 0),
 payment_status text not null default 'Pending' check (payment_status in ('Pending','Processing','Paid','Failed','Cancelled')),
 payment_method text,
 transaction_reference text,
 paid_at timestamptz,
 notes text,
 created_at timestamptz not null default now()
);

create table if not exists public.task_updates (
 id uuid primary key default gen_random_uuid(),
 task_id uuid not null references public.tasks(id) on delete cascade,
 assignment_id uuid references public.assignments(id) on delete set null,
 updated_by uuid,
 old_status text,
 new_status text,
 message text,
 created_at timestamptz not null default now()
);

create table if not exists public.attachments (
 id uuid primary key default gen_random_uuid(),
 task_id uuid not null references public.tasks(id) on delete cascade,
 assignment_id uuid references public.assignments(id) on delete set null,
 file_url text not null,
 file_name text not null,
 file_type text,
 uploaded_by uuid,
 created_at timestamptz not null default now()
);

create table if not exists public.categories (
 id uuid primary key default gen_random_uuid(),
 name text unique not null,
 created_at timestamptz not null default now()
);

create index if not exists idx_tasks_status on public.tasks(status);
create index if not exists idx_tasks_deadline on public.tasks(deadline);
create index if not exists idx_requirements_task on public.part_time_requirements(task_id);
create index if not exists idx_assignments_task on public.assignments(task_id);
create index if not exists idx_assignments_person on public.assignments(person_id);
create index if not exists idx_payments_status on public.payments(payment_status);

insert into public.categories(name) values
('Delivery'),
('Errands'),
('Documents'),
('Data Entry'),
('Online Work'),
('Household'),
('Event Assistance'),
('Tutoring'),
('Photography'),
('Other')
on conflict do nothing;

alter table public.people enable row level security;
alter table public.tasks enable row level security;
alter table public.part_time_requirements enable row level security;
alter table public.assignments enable row level security;
alter table public.payments enable row level security;
alter table public.task_updates enable row level security;
alter table public.attachments enable row level security;
alter table public.categories enable row level security;

create policy "dev people" on public.people for all using (true) with check (true);
create policy "dev tasks" on public.tasks for all using (true) with check (true);
create policy "dev requirements" on public.part_time_requirements for all using (true) with check (true);
create policy "dev assignments" on public.assignments for all using (true) with check (true);
create policy "dev payments" on public.payments for all using (true) with check (true);
create policy "dev updates" on public.task_updates for all using (true) with check (true);
create policy "dev attachments" on public.attachments for all using (true) with check (true);
create policy "dev categories" on public.categories for all using (true) with check (true);
