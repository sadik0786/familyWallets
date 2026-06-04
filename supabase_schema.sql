-- 1. ENABLE UUID GENERATION
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. CREATE USERS TABLE (PROFILES)
-- Extends auth.users
CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    display_name TEXT,
    avatar_url TEXT,
    role TEXT NOT NULL DEFAULT 'user', -- 'user' or 'super_admin'
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 3. CREATE FAMILIES TABLE
CREATE TABLE public.families (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    invite_code TEXT UNIQUE NOT NULL,
    created_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
    subscription_tier TEXT NOT NULL DEFAULT 'free', -- 'free', 'premium'
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 4. CREATE FAMILY_MEMBERS TABLE
CREATE TABLE public.family_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID NOT NULL REFERENCES public.families(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'member', -- 'admin', 'manager', 'member', 'viewer'
    joined_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE(family_id, user_id)
);

-- 6. CREATE CONTRIBUTIONS TABLE
CREATE TABLE public.contributions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID NOT NULL REFERENCES public.families(id) ON DELETE CASCADE,
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    contributor_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    contributor_name TEXT NOT NULL, -- Saved display name for historical records
    note TEXT,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 7. CREATE EXPENSES TABLE
CREATE TABLE public.expenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID NOT NULL REFERENCES public.families(id) ON DELETE CASCADE,
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    category TEXT NOT NULL, -- 'Grocery', 'Electricity', 'Water', 'Gas', 'Rent', 'Internet', etc.
    description TEXT,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    added_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
    added_by_name TEXT NOT NULL,
    receipt_url TEXT, -- Link to Supabase storage file
    recurring_rule_id UUID, -- References recurring rules if any
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 8. CREATE BUDGET_LIMITS TABLE
CREATE TABLE public.budget_limits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID NOT NULL REFERENCES public.families(id) ON DELETE CASCADE,
    category TEXT NOT NULL, -- 'All' or specific category
    limit_amount NUMERIC(12, 2) NOT NULL CHECK (limit_amount > 0),
    month INT NOT NULL CHECK (month BETWEEN 1 AND 12),
    year INT NOT NULL CHECK (year >= 2020),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE(family_id, category, month, year)
);

-- 9. CREATE RECURRING_RULES TABLE
CREATE TABLE public.recurring_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID NOT NULL REFERENCES public.families(id) ON DELETE CASCADE,
    type TEXT NOT NULL, -- 'expense', 'contribution'
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    category TEXT,
    description TEXT,
    interval TEXT NOT NULL DEFAULT 'monthly', -- 'weekly', 'monthly', 'yearly'
    day_of_month INT CHECK (day_of_month BETWEEN 1 AND 31),
    is_active BOOLEAN NOT NULL DEFAULT true,
    last_processed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 10. CREATE ACTIVITY_LOGS TABLE
CREATE TABLE public.activity_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID NOT NULL REFERENCES public.families(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    user_name TEXT NOT NULL,
    action TEXT NOT NULL, -- e.g. 'added_expense', 'invited_member'
    details TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 11. CREATE NOTIFICATIONS TABLE
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID NOT NULL REFERENCES public.families(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL, -- 'low_balance', 'monthly_summary', 'upcoming_bills', 'member_activity'
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 12. CREATE SUBSCRIPTIONS TABLE
CREATE TABLE public.subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID NOT NULL REFERENCES public.families(id) ON DELETE CASCADE,
    tier TEXT NOT NULL DEFAULT 'free', -- 'free', 'premium'
    status TEXT NOT NULL DEFAULT 'active', -- 'active', 'cancelled', 'expired'
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 13. INDEXES FOR PERFORMANCE Optimization
CREATE INDEX idx_family_members_user ON public.family_members(user_id);
CREATE INDEX idx_family_members_family ON public.family_members(family_id);
CREATE INDEX idx_expenses_family ON public.expenses(family_id);
CREATE INDEX idx_contributions_family ON public.contributions(family_id);
CREATE INDEX idx_notifications_user ON public.notifications(user_id);

-- 14. ROW LEVEL SECURITY (RLS) POLICIES
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.families ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.family_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contributions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.budget_limits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recurring_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

-- Profiles: Anyone signed in can read, user can edit their own
CREATE POLICY "Allow public read users" ON public.users FOR SELECT USING (true);
CREATE POLICY "Allow user edit own profile" ON public.users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Allow system insert users" ON public.users FOR INSERT WITH CHECK (true);

-- Helper Security Function to verify if user is member of a family
CREATE OR REPLACE FUNCTION public.is_family_member(family_uuid UUID)
RETURNS BOOLEAN SECURITY DEFINER AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.family_members
        WHERE family_members.family_id = family_uuid AND family_members.user_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql;

-- Families policies
CREATE POLICY "Allow select families if member" ON public.families 
    FOR SELECT USING (public.is_family_member(id));
CREATE POLICY "Allow create family" ON public.families 
    FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update family if admin member" ON public.families 
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.family_members
            WHERE family_members.family_id = id 
            AND family_members.user_id = auth.uid() 
            AND family_members.role IN ('admin', 'manager')
        )
    );

-- Family Members policies
CREATE POLICY "Allow select members if member" ON public.family_members
    FOR SELECT USING (public.is_family_member(family_id));
CREATE POLICY "Allow join family" ON public.family_members
    FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow admin edit members" ON public.family_members
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.family_members admin_check
            WHERE admin_check.family_id = family_members.family_id 
            AND admin_check.user_id = auth.uid() 
            AND admin_check.role = 'admin'
        )
    );

-- Shared Family Data policies (expenses, contributions, budget limits, notifications, subscriptions, logs, recurring)

CREATE POLICY "Family isolation SELECT contributions" ON public.contributions FOR SELECT USING (public.is_family_member(family_id));
CREATE POLICY "Family isolation INSERT contributions" ON public.contributions FOR INSERT WITH CHECK (public.is_family_member(family_id));
CREATE POLICY "Family isolation UPDATE contributions" ON public.contributions FOR UPDATE USING (public.is_family_member(family_id));
CREATE POLICY "Family isolation DELETE contributions" ON public.contributions FOR DELETE USING (public.is_family_member(family_id));

CREATE POLICY "Family isolation SELECT expenses" ON public.expenses FOR SELECT USING (public.is_family_member(family_id));
CREATE POLICY "Family isolation INSERT expenses" ON public.expenses FOR INSERT WITH CHECK (public.is_family_member(family_id));
CREATE POLICY "Family isolation UPDATE expenses" ON public.expenses FOR UPDATE USING (public.is_family_member(family_id));
CREATE POLICY "Family isolation DELETE expenses" ON public.expenses FOR DELETE USING (public.is_family_member(family_id));

CREATE POLICY "Family isolation SELECT budgets" ON public.budget_limits FOR SELECT USING (public.is_family_member(family_id));
CREATE POLICY "Family isolation INSERT budgets" ON public.budget_limits FOR INSERT WITH CHECK (public.is_family_member(family_id));
CREATE POLICY "Family isolation UPDATE budgets" ON public.budget_limits FOR UPDATE USING (public.is_family_member(family_id));
CREATE POLICY "Family isolation DELETE budgets" ON public.budget_limits FOR DELETE USING (public.is_family_member(family_id));

CREATE POLICY "Family isolation SELECT recurring" ON public.recurring_rules FOR SELECT USING (public.is_family_member(family_id));
CREATE POLICY "Family isolation INSERT recurring" ON public.recurring_rules FOR INSERT WITH CHECK (public.is_family_member(family_id));
CREATE POLICY "Family isolation UPDATE recurring" ON public.recurring_rules FOR UPDATE USING (public.is_family_member(family_id));
CREATE POLICY "Family isolation DELETE recurring" ON public.recurring_rules FOR DELETE USING (public.is_family_member(family_id));

CREATE POLICY "Family isolation SELECT logs" ON public.activity_logs FOR SELECT USING (public.is_family_member(family_id));
CREATE POLICY "Family isolation INSERT logs" ON public.activity_logs FOR INSERT WITH CHECK (public.is_family_member(family_id));

CREATE POLICY "Family isolation SELECT notifications" ON public.notifications FOR SELECT USING (public.is_family_member(family_id));
CREATE POLICY "Family isolation UPDATE notifications" ON public.notifications FOR UPDATE USING (public.is_family_member(family_id));

CREATE POLICY "Family isolation SELECT subscriptions" ON public.subscriptions FOR SELECT USING (public.is_family_member(family_id));

-- 15. AUTOMATIC PROFILE GENERATION TRIGGER ON AUTH SIGNUP
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, display_name, avatar_url, role)
    VALUES (
        new.id,
        new.email,
        coalesce(new.raw_user_meta_data->>'display_name', split_part(new.email, '@', 1)),
        new.raw_user_meta_data->>'avatar_url',
        'user'
    );
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 16. SUPER ADMIN METRICS RPC
CREATE OR REPLACE FUNCTION get_super_admin_stats()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    caller_role text;
    total_users int;
    total_families int;
    total_revenue numeric;
    families_feed json;
    users_feed json;
BEGIN
    SELECT role INTO caller_role FROM public.users WHERE id = auth.uid();
    
    IF caller_role != 'super_admin' THEN
        RAISE EXCEPTION 'Access Denied: Not a super admin';
    END IF;

    SELECT count(*) INTO total_users FROM public.users;
    SELECT count(*) INTO total_families FROM public.families;
    SELECT COALESCE(SUM(1000), 0) INTO total_revenue FROM public.subscriptions WHERE tier = 'premium' AND status = 'active';

    SELECT json_agg(row_to_json(f)) INTO families_feed
    FROM (
        SELECT 
            f.id,
            f.name,
            f.invite_code,
            f.created_at,
            f.is_active,
            f.subscription_tier as plan,
            (SELECT count(*) FROM public.family_members fm WHERE fm.family_id = f.id) as member_count
        FROM public.families f
        ORDER BY f.created_at DESC
        LIMIT 50
    ) f;

    SELECT json_agg(row_to_json(u)) INTO users_feed
    FROM (
        SELECT 
            id,
            display_name,
            email,
            role,
            created_at
        FROM public.users
        ORDER BY created_at DESC
        LIMIT 100
    ) u;

    RETURN json_build_object(
        'totalUsers', total_users,
        'totalFamilies', total_families,
        'totalRevenue', total_revenue,
        'activeFamilies', COALESCE(families_feed, '[]'::json),
        'allUsers', COALESCE(users_feed, '[]'::json)
    );
END;
$$;

-- 17. SUPER ADMIN TOGGLE FAMILY STATUS RPC
CREATE OR REPLACE FUNCTION toggle_family_status(target_family_id UUID, new_status BOOLEAN)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    caller_role text;
BEGIN
    -- Verify caller is super_admin
    SELECT role INTO caller_role FROM public.users WHERE id = auth.uid();
    
    IF caller_role != 'super_admin' THEN
        RAISE EXCEPTION 'Access Denied: Not a super admin';
    END IF;

    -- Update the family
    UPDATE public.families SET is_active = new_status WHERE id = target_family_id;
    
    RETURN true;
END;
$$;

-- 18. JOIN WORKSPACE RPC (Bypasses RLS to allow finding and joining a family by invite code)
CREATE OR REPLACE FUNCTION join_workspace_by_code(p_invite_code text, p_user_id uuid)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_family_id uuid;
    v_family_record json;
    v_is_active boolean;
BEGIN
    -- 1. Find the family by invite code
    SELECT id, is_active INTO v_family_id, v_is_active
    FROM public.families 
    WHERE invite_code = p_invite_code;

    -- 2. If not found or inactive, return null
    IF v_family_id IS NULL OR v_is_active = false THEN
        RETURN NULL;
    END IF;

    -- 3. Check if user is already a member
    IF EXISTS (SELECT 1 FROM public.family_members WHERE family_id = v_family_id AND user_id = p_user_id) THEN
        -- If already a member, just return the family
        SELECT row_to_json(f) INTO v_family_record FROM public.families f WHERE id = v_family_id;
        RETURN v_family_record;
    END IF;

    -- 4. Insert the user as a new member
    INSERT INTO public.family_members (family_id, user_id, role)
    VALUES (v_family_id, p_user_id, 'member');

    -- 5. Return the family object
    SELECT row_to_json(f) INTO v_family_record FROM public.families f WHERE id = v_family_id;
    RETURN v_family_record;
END;
$$;
