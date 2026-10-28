'use client';

import { FiUsers } from 'react-icons/fi';
import UserList from '@/components/UserList';

/**
 * Users page — every account in the system (all roles), searchable and
 * filterable; supports suspend/activate and delete.
 */
export default function UsersPage() {
  return (
    <UserList
      title="Users"
      description="All accounts — passengers, drivers and staff."
      headerIcon={FiUsers}
    />
  );
}
