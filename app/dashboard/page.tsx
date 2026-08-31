import { createClient } from "@/lib/supabase/server";

export default async function DashboardPage() {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  return (
    <main className="min-h-screen bg-black p-8 text-white">
      <div className="mx-auto max-w-5xl">
        <p className="text-sm text-white/50">OPERON</p>

        <h1 className="mt-2 text-4xl font-bold">
          Digital Employee Dashboard
        </h1>

        <p className="mt-4 text-white/60">
          {user?.email ?? "Authenticated user"}
        </p>

        <div className="mt-10 grid gap-4 md:grid-cols-3">
          <div className="rounded-xl border border-white/10 bg-white/5 p-6">
            <p className="text-sm text-white/50">Customers</p>
            <p className="mt-2 text-3xl font-bold">0</p>
          </div>

          <div className="rounded-xl border border-white/10 bg-white/5 p-6">
            <p className="text-sm text-white/50">Follow-ups</p>
            <p className="mt-2 text-3xl font-bold">0</p>
          </div>

          <div className="rounded-xl border border-white/10 bg-white/5 p-6">
            <p className="text-sm text-white/50">AI Actions</p>
            <p className="mt-2 text-3xl font-bold">0</p>
          </div>
        </div>
      </div>
    </main>
  );
}
