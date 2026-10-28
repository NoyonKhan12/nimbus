'use client';

import { useParams } from 'next/navigation';
import { VehicleDetailView } from '@/components/DetailViews';

/** Vehicle detail route. */
export default function VehicleDetailPage() {
  const params = useParams<{ id: string }>();
  return <VehicleDetailView id={String(params.id)} />;
}
