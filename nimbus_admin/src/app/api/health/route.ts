/**
 * Simple health check endpoint for Docker healthchecks.
 * Returns 200 OK with a JSON status payload.
 */
export async function GET() {
  return Response.json({ status: 'ok', service: 'nimbus-admin' });
}
