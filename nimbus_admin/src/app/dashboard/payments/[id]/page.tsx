'use client';

import { useParams } from 'next/navigation';
import { PaymentDetailView } from '@/components/DetailViews';

/** PaymentDetail detail route. */
export default function PaymentDetailDetailPage() {
  const params = useParams<{ id: string }>();
  return <PaymentDetailView id={String(params.id)} />;
}
