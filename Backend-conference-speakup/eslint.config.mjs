import js from "@eslint/js";
import stylisticJs from "@stylistic/eslint-plugin-js";
import nodePlugin from "eslint-plugin-n";
import prettier from "eslint-config-prettier";

export default [
  js.configs.recommended,
  prettier,
  {
    plugins: {
      "@stylistic/js": stylisticJs,
      n: nodePlugin,
    },
    languageOptions: {
      ecmaVersion: 2024,
      sourceType: "module",
      globals: {
        console: "readonly",
        process: "readonly",
        Buffer: "readonly",
        __dirname: "readonly",
        __filename: "readonly",
        setTimeout: "readonly",
        setInterval: "readonly",
        clearTimeout: "readonly",
        clearInterval: "readonly",
        URL: "readonly",
        URLSearchParams: "readonly",
        fetch: "readonly",
        AbortController: "readonly",
        FormData: "readonly",
        crypto: "readonly",
      },
    },
    rules: {
      "no-unused-vars": ["warn", { argsIgnorePattern: "^_" }],
      "no-console": "off",
      "prefer-const": "error",
      "no-var": "error",
      eqeqeq: ["error", "always"],
      "n/no-missing-import": "off",
      "n/no-unsupported-features/es-syntax": "off",
    },
  },
  {
    ignores: ["node_modules/", "prisma/", "logs/", "coverage/", "dist/"],
  },
];
