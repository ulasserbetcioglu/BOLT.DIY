-- Drop existing policies
DROP POLICY IF EXISTS "Companies manage field staff" ON field_staff;
DROP POLICY IF EXISTS "Staff view own data" ON field_staff;
DROP POLICY IF EXISTS "Admin manage all staff" ON field_staff;

-- Create new policies with proper permissions
CREATE POLICY "Companies manage field staff"
ON field_staff FOR ALL
TO authenticated
USING (
  company_id IN (
    SELECT id FROM companies
    WHERE user_id = auth.uid()
  )
)
WITH CHECK (
  company_id IN (
    SELECT id FROM companies
    WHERE user_id = auth.uid()
  )
);

CREATE POLICY "Staff view own data"
ON field_staff FOR SELECT
TO authenticated
USING (
  user_id = auth.uid()
);

CREATE POLICY "Admin manage all staff"
ON field_staff FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE auth.users.id = auth.uid()
    AND auth.users.email LIKE '%@admin%'
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE auth.users.id = auth.uid()
    AND auth.users.email LIKE '%@admin%'
  )
);

-- Grant necessary permissions
GRANT ALL ON field_staff TO authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;
