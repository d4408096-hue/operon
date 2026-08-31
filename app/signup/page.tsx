"use client";

import { FormEvent, useState } from "react";
import { createClient } from "@/lib/supabase/client";

export default function SignupPage() {
  const supabase = createClient();

  const [name, setName] = useState("");
  const [businessName, setBusinessName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [message, setMessage] = useState("");
  const [loading, setLoading] = useState(false);

  async function handleSignup(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    setLoading(true);
    setMessage("");

    const { data, error } = await supabase.auth.signUp({
      email,
      password,
    });

    if (error) {
      setMessage(error.message);
      setLoading(false);
      return;
    }

    if (!data.user) {
      setMessage("Account creation failed.");
      setLoading(false);
      return;
    }

    const { error: bootstrapError } = await supabase.rpc(
      "create_business_for_current_user",
      {
        business_name: businessName,
        user_name: name,
      }
    );

    if (bootstrapError) {
      setMessage(bootstrapError.message);
      setLoading(false);
      return;
    }

    window.location.href = "/dashboard";
  }

  return (
    <main className="flex min-h-screen items-center justify-center bg-black px-6 text-white">
      <div className="w-full max-w-md rounded-2xl border border-white/10 bg-white/5 p-8">
        <h1 className="mb-2 text-3xl font-bold">Create your Operon</h1>

        <p className="mb-8 text-sm text-white/60">
          Set up your digital employee infrastructure.
        </p>

        <form onSubmit={handleSignup} className="space-y-5">
          <div>
            <label className="mb-2 block text-sm">Your name</label>

            <input
              type="text"
              required
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="w-full rounded-lg border border-white/10 bg-white/5 px-4 py-3 outline-none"
              placeholder="Your name"
            />
          </div>

          <div>
            <label className="mb-2 block text-sm">Business name</label>

            <input
              type="text"
              required
              value={businessName}
              onChange={(e) => setBusinessName(e.target.value)}
              className="w-full rounded-lg border border-white/10 bg-white/5 px-4 py-3 outline-none"
              placeholder="Your business"
            />
          </div>

          <div>
            <label className="mb-2 block text-sm">Email</label>

            <input
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full rounded-lg border border-white/10 bg-white/5 px-4 py-3 outline-none"
              placeholder="you@example.com"
            />
          </div>

          <div>
            <label className="mb-2 block text-sm">Password</label>

            <input
              type="password"
              required
              minLength={6}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full rounded-lg border border-white/10 bg-white/5 px-4 py-3 outline-none"
              placeholder="At least 6 characters"
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full rounded-lg bg-white px-4 py-3 font-semibold text-black disabled:opacity-50"
          >
            {loading ? "Creating Operon..." : "Create Operon"}
          </button>
        </form>

        {message && (
          <p className="mt-5 text-sm text-white/70">
            {message}
          </p>
        )}

        <p className="mt-6 text-center text-sm text-white/50">
          Already have an account?{" "}
          <a href="/login" className="text-white underline">
            Sign in
          </a>
        </p>
      </div>
    </main>
  );
}
