-- =====================================================================
-- AKK Spices ANDROID APP  (mobile OTP registration + profile)
-- Supabase Dashboard -> SQL Editor -> New query -> paste ALL -> Run
-- Safe to run more than once.
-- =====================================================================

-- 1) CUSTOMERS (normal buyers who register in the app with mobile OTP)
--    A row exists only after the customer has completed the profile,
--    so "row exists" = "profile complete" = allowed to place an order.
create table if not exists customers (
  id uuid references auth.users on delete cascade primary key,
  phone text,
  full_name text not null,
  email text,
  address_line text not null,
  city text not null,
  state text not null,
  pincode text not null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table customers enable row level security;

drop policy if exists "Customers view own profile"   on customers;
drop policy if exists "Customers insert own profile" on customers;
drop policy if exists "Customers update own profile" on customers;

create policy "Customers view own profile"   on customers for select using (auth.uid() = id);
create policy "Customers insert own profile" on customers for insert with check (auth.uid() = id);
create policy "Customers update own profile" on customers for update using (auth.uid() = id) with check (auth.uid() = id);

-- 2) SECURITY FIX for partners (important!)
--    Old rule only checked "auth.uid() = id", so a signed-up user could insert their own
--    partner row with status = 'approved' straight from the browser.
--    New rule: a new partner row can only be created as 'pending'. Only YOU approve (Table Editor).
drop policy if exists "Partners can insert own profile" on partners;
create policy "Partners can insert own profile" on partners
  for insert with check (auth.uid() = id and status = 'pending');
