-- OPERON V1
-- 002_auth_bootstrap.sql

create or replace function public.create_business_for_current_user(
    business_name text,
    user_name text
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
    new_business_id uuid;
begin
    -- Require authentication.
    if auth.uid() is null then
        raise exception 'Authentication required';
    end if;

    -- Prevent duplicate bootstrap for the same Auth user.
    if exists (
        select 1
        from public.users
        where id = auth.uid()
    ) then
        raise exception 'User is already associated with a business';
    end if;

    -- Validate inputs.
    if business_name is null
       or length(trim(business_name)) = 0 then
        raise exception 'Business name is required';
    end if;

    if user_name is null
       or length(trim(user_name)) = 0 then
        raise exception 'User name is required';
    end if;

    -- Create the business.
    insert into public.businesses (name)
    values (trim(business_name))
    returning id into new_business_id;

    -- Make the authenticated user the owner.
    insert into public.users (
        id,
        business_id,
        name,
        role
    )
    values (
        auth.uid(),
        new_business_id,
        trim(user_name),
        'owner'
    );

    return new_business_id;
end;
$$;

revoke all on function public.create_business_for_current_user(text, text)
from public;

grant execute
on function public.create_business_for_current_user(text, text)
to authenticated;
