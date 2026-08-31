"use client";

import { useEffect, useState } from "react";
import { createClient } from "@/lib/supabase";

export default function SupabaseTest() {
  const [status, setStatus] = useState("Testing connection...");

  useEffect(() => {
    async function testConnection() {
      const supabase = createClient();

      const { error } = await supabase
        .from("customers")
        .select("id")
        .limit(1);

      if (error) {
        setStatus(`Connected to Supabase. Database response: ${error.message}`);
      } else {
        setStatus("Supabase connection successful.");
      }
    }

    testConnection();
  }, []);

  return (
    <main className="flex min-h-screen items-center justify-center p-8">
      <div className="rounded-xl border p-8">
        <h1 className="text-2xl font-bold">Operon</h1>
        <p className="mt-4">{status}</p>
      </div>
    </main>
  );
}
