'use client';

import { useParams } from 'next/navigation';
import { UserDetailView } from '@/components/DetailViews';

/** Passenger detail — same full account view, with "Back to passengers". */
export default function PassengerDetailPage() {
  const params = useParams<{ id: string }>();
  return <UserDetailView id={String(params.id)} carrier="passengers" />;
}
