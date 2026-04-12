"use client";

import { useState } from "react";
import { Card } from "@/components/ui";
import {
  Sparkles,
  Send,
  Bot,
  User,
  Mic,
  FileText,
  Brain,
  Lightbulb,
  MessageSquare,
} from "lucide-react";

interface Message {
  id: string;
  role: "user" | "assistant";
  content: string;
  timestamp: Date;
}

const suggestions = [
  { icon: FileText, text: "Summarize my last meeting" },
  { icon: Brain, text: "Generate action items from today" },
  { icon: Lightbulb, text: "Suggest an agenda for standup" },
  { icon: MessageSquare, text: "Draft a follow-up email" },
];

export default function AIAssistantPage() {
  const [messages, setMessages] = useState<Message[]>([
    {
      id: "1",
      role: "assistant",
      content:
        "Hi! I'm your SpeakUp AI assistant. I can help summarize meetings, generate action items, draft follow-up emails, and more. What would you like help with?",
      timestamp: new Date(),
    },
  ]);
  const [input, setInput] = useState("");
  const [isTyping, setIsTyping] = useState(false);

  const handleSend = () => {
    if (!input.trim()) return;

    const userMessage: Message = {
      id: Date.now().toString(),
      role: "user",
      content: input.trim(),
      timestamp: new Date(),
    };

    setMessages((prev) => [...prev, userMessage]);
    setInput("");
    setIsTyping(true);

    // Simulate AI response
    setTimeout(() => {
      const aiResponse: Message = {
        id: (Date.now() + 1).toString(),
        role: "assistant",
        content:
          "I'd be happy to help with that! This feature is powered by our AI backend. Once connected, I'll be able to analyze your meeting transcripts, generate summaries, and provide intelligent suggestions based on your conversation history.",
        timestamp: new Date(),
      };
      setMessages((prev) => [...prev, aiResponse]);
      setIsTyping(false);
    }, 1500);
  };

  const handleSuggestion = (text: string) => {
    setInput(text);
  };

  return (
    <div className="mx-auto flex h-full max-w-4xl flex-col p-6">
      {/* Header */}
      <div className="mb-6">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-purple-500 to-pink-500">
            <Sparkles className="h-5 w-5 text-white" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-text-primary">AI Assistant</h1>
            <p className="text-sm text-text-secondary">Powered by SpeakUp AI</p>
          </div>
        </div>
      </div>

      {/* Messages area */}
      <div className="flex-1 overflow-y-auto space-y-4 mb-4">
        {messages.map((msg) => (
          <div
            key={msg.id}
            className={`flex gap-3 ${msg.role === "user" ? "flex-row-reverse" : ""}`}
          >
            <div
              className={`flex h-9 w-9 shrink-0 items-center justify-center rounded-xl ${
                msg.role === "assistant"
                  ? "bg-gradient-to-br from-purple-500 to-pink-500"
                  : "bg-primary"
              }`}
            >
              {msg.role === "assistant" ? (
                <Bot className="h-4 w-4 text-white" />
              ) : (
                <User className="h-4 w-4 text-white" />
              )}
            </div>
            <div
              className={`max-w-[75%] rounded-2xl px-4 py-3 ${
                msg.role === "user"
                  ? "bg-primary text-white"
                  : "bg-card border border-border text-text-primary"
              }`}
            >
              <p className="text-sm leading-relaxed">{msg.content}</p>
              <p
                className={`mt-1 text-[10px] ${
                  msg.role === "user" ? "text-white/60" : "text-text-tertiary"
                }`}
              >
                {msg.timestamp.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })}
              </p>
            </div>
          </div>
        ))}

        {isTyping && (
          <div className="flex gap-3">
            <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-gradient-to-br from-purple-500 to-pink-500">
              <Bot className="h-4 w-4 text-white" />
            </div>
            <div className="rounded-2xl bg-card border border-border px-4 py-3">
              <div className="flex gap-1">
                <span className="h-2 w-2 rounded-full bg-text-tertiary animate-bounce" style={{ animationDelay: "0ms" }} />
                <span className="h-2 w-2 rounded-full bg-text-tertiary animate-bounce" style={{ animationDelay: "150ms" }} />
                <span className="h-2 w-2 rounded-full bg-text-tertiary animate-bounce" style={{ animationDelay: "300ms" }} />
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Suggestions */}
      {messages.length <= 1 && (
        <div className="grid grid-cols-2 gap-2 mb-4">
          {suggestions.map((s) => (
            <button
              key={s.text}
              onClick={() => handleSuggestion(s.text)}
              className="flex items-center gap-2.5 rounded-xl border border-border bg-card p-3 text-left text-sm text-text-secondary hover:border-primary/30 hover:text-text-primary transition-colors"
            >
              <s.icon className="h-4 w-4 text-primary shrink-0" />
              <span className="line-clamp-1">{s.text}</span>
            </button>
          ))}
        </div>
      )}

      {/* Input */}
      <div className="flex items-center gap-3 rounded-2xl border border-border bg-card p-2">
        <button className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl hover:bg-bg-secondary text-text-tertiary transition-colors">
          <Mic className="h-5 w-5" />
        </button>
        <input
          type="text"
          placeholder="Ask me anything about your meetings..."
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={(e) => e.key === "Enter" && handleSend()}
          className="flex-1 bg-transparent text-sm text-text-primary placeholder:text-text-tertiary outline-none"
        />
        <button
          onClick={handleSend}
          disabled={!input.trim()}
          className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-primary text-white disabled:opacity-40 hover:brightness-110 transition-all"
        >
          <Send className="h-4 w-4" />
        </button>
      </div>
    </div>
  );
}
