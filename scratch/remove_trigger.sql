-- DROP THE TRIGGER THAT IS CAUSING THE CRASH
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();
