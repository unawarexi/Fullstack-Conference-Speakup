"use client";

import { useCurrentUser, useSignOut, useDeleteAccount } from "@/hooks/use-auth";
import { useUpdateProfile, useUpdateAvatar } from "@/hooks/use-user";
import { useThemeStore } from "@/store/theme-store";
import { Avatar, Button, Input, Card, Modal } from "@/components/ui";
import { Select } from "@/components/ui/dropdown";
import { strings } from "@/config/strings";
import {
  Moon,
  Sun,
  Monitor,
  Camera,
  LogOut,
  Trash2,
  User,
  Bell,
  Shield,
  Palette,
} from "lucide-react";
import { useRef, useState } from "react";

export default function SettingsPage() {
  const { data: user } = useCurrentUser();
  const { mutate: updateProfile, isPending: updatingProfile } = useUpdateProfile();
  const { mutate: updateAvatar, isPending: updatingAvatar } = useUpdateAvatar();
  const { mutate: signOut } = useSignOut();
  const { mutate: deleteAccount, isPending: deleting } = useDeleteAccount();
  const { theme, setTheme } = useThemeStore();

  const [name, setName] = useState(user?.name ?? "");
  const [showDelete, setShowDelete] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleAvatarChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    updateAvatar(file);
  };

  const handleSaveProfile = () => {
    if (name.trim() && name !== user?.name) {
      updateProfile({ fullName: name.trim() });
    }
  };

  return (
    <div className="mx-auto max-w-3xl p-6 space-y-8">
      <h1 className="text-2xl font-bold text-textPrimary">{strings.settings.title}</h1>

      {/* Profile section */}
      <Card className="p-6 space-y-6">
        <div className="flex items-center gap-2 text-textPrimary">
          <User className="h-5 w-5" />
          <h2 className="text-lg font-semibold">{strings.settings.profile}</h2>
        </div>

        <div className="flex items-center gap-6">
          <div className="relative">
            <Avatar
              src={user?.avatar}
              name={user?.name}
              size="xl"
            />
            <button
              onClick={() => fileInputRef.current?.click()}
              disabled={updatingAvatar}
              className="absolute -bottom-1 -right-1 flex h-8 w-8 items-center justify-center rounded-full bg-primary text-white shadow-lg hover:bg-primary/90 transition-colors"
            >
              <Camera className="h-4 w-4" />
            </button>
            <input
              ref={fileInputRef}
              type="file"
              accept="image/*"
              className="hidden"
              onChange={handleAvatarChange}
            />
          </div>
          <div>
            <p className="font-semibold text-textPrimary">{user?.name}</p>
            <p className="text-sm text-textSecondary">{user?.email}</p>
          </div>
        </div>

        <div className="space-y-4">
          <Input
            label="Display Name"
            value={name}
            onChange={(e) => setName(e.target.value)}
          />
          <Button
            onClick={handleSaveProfile}
            loading={updatingProfile}
            disabled={!name.trim() || name === user?.name}
          >
            Save Changes
          </Button>
        </div>
      </Card>

      {/* Appearance */}
      <Card className="p-6 space-y-6">
        <div className="flex items-center gap-2 text-textPrimary">
          <Palette className="h-5 w-5" />
          <h2 className="text-lg font-semibold">Appearance</h2>
        </div>

        <div className="flex gap-3">
          {([
            { value: "light", icon: Sun, label: "Light" },
            { value: "dark", icon: Moon, label: "Dark" },
            { value: "system", icon: Monitor, label: "System" },
          ] as const).map((opt) => (
            <button
              key={opt.value}
              onClick={() => setTheme(opt.value)}
              className={`flex flex-1 flex-col items-center gap-2 rounded-xl border p-4 transition-colors ${
                theme === opt.value
                  ? "border-primary bg-primary/5 text-primary"
                  : "border-border text-textSecondary hover:border-primary/30"
              }`}
            >
              <opt.icon className="h-6 w-6" />
              <span className="text-sm font-medium">{opt.label}</span>
            </button>
          ))}
        </div>
      </Card>

      {/* Account actions */}
      <Card className="p-6 space-y-4">
        <div className="flex items-center gap-2 text-textPrimary">
          <Shield className="h-5 w-5" />
          <h2 className="text-lg font-semibold">{strings.settings.account}</h2>
        </div>

        <div className="flex flex-col gap-3 sm:flex-row">
          <Button
            variant="outline"
            className="gap-2"
            onClick={() => signOut()}
          >
            <LogOut className="h-4 w-4" />
            {strings.settings.signOut}
          </Button>
          <Button
            variant="danger"
            className="gap-2"
            onClick={() => setShowDelete(true)}
          >
            <Trash2 className="h-4 w-4" />
            {strings.settings.deleteAccount}
          </Button>
        </div>
      </Card>

      <Modal
        open={showDelete}
        onClose={() => setShowDelete(false)}
        title="Delete Account"
        description="This action is permanent and cannot be undone. All your data will be deleted."
        confirmLabel="Delete My Account"
        onConfirm={() => deleteAccount()}
        loading={deleting}
        danger
      />
    </div>
  );
}
