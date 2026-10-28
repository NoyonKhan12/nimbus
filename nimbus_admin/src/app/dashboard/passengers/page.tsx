'use client';

import { LuUserRound } from 'react-icons/lu';
import UserList from '@/components/UserList';

/**
 * Passengers page — accounts with the PASSENGER role only.
 */
export default function PassengersPage() {
  return (
    <UserList
      title="Passengers"
      description="Passenger accounts registered in the system."
      fixedRole="PASSENGER"
      headerIcon={LuUserRound}
    />
  );
}
