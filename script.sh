#!/bin/bash

# Prompt for the project name
read -p "Enter the name of your project: " project_name

# Prompt for package manager choice
read -p "Do you want to use Bun or NPM? (bun/npm): " package_manager

if [[ "$package_manager" != "bun" && "$package_manager" != "npm" ]]; then
  echo "Invalid choice. Please choose 'bun' or 'npm'."
  exit 1
fi

# Step 1: Create a new Vite project
echo "Creating a new Vite project..."
if [[ "$package_manager" == "bun" ]]; then
  bun create vite@latest "$project_name" --template react-ts
else
  npx create-vite@latest "$project_name" --template react-ts
fi
cd "$project_name" || exit

# Step 2: Install Tailwind CSS and its peer dependencies
echo "Installing Tailwind CSS..."
if [[ "$package_manager" == "bun" ]]; then
  bun add -D tailwindcss postcss autoprefixer
  bunx --bun tailwindcss init -p
else
  npm install -D tailwindcss postcss autoprefixer
  npx tailwindcss init -p
fi

# Step 3: Update Tailwind configuration
echo "Configuring Tailwind CSS..."
cat <<EOT > tailwind.config.js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./index.html", "./src/**/*.{ts,tsx,js,jsx}"],
  theme: {
    extend: {},
  },
  plugins: [require("tailwindcss-animate")],
}
EOT

# Add Tailwind imports to the main CSS file
echo "@tailwind base;" > src/index.css
echo "@tailwind components;" >> src/index.css
echo "@tailwind utilities;" >> src/index.css

# Step 4: Install TailwindCSS plugins (tailwindcss-animate)
echo "Installing TailwindCSS plugins (tailwindcss-animate)..."
if [[ "$package_manager" == "bun" ]]; then
  bun add -D tailwindcss-animate
else
  npm install -D tailwindcss-animate
fi

# Step 5: Update TypeScript configuration for tsconfig.json
echo "Configuring tsconfig.json..."
cat <<EOT > tsconfig.json
{
  "files": [],
  "references": [
    {
      "path": "./tsconfig.app.json"
    },
    {
      "path": "./tsconfig.node.json"
    }
  ],
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}
EOT

# Step 6: Update tsconfig.app.json
echo "Configuring tsconfig.app.json..."
cat <<EOT > tsconfig.app.json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,

    /* Bundler mode */
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "isolatedModules": true,
    "moduleDetection": "force",
    "noEmit": true,
    "jsx": "react-jsx",

    /* Linting */
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,

    "baseUrl": ".",
    "paths": {
      "@/*": [
        "./src/*"
      ]
    }
  },
  "include": ["src"]
}
EOT

# Step 7: Configure Vite with path alias
echo "Configuring vite.config.ts..."
if [[ "$package_manager" == "bun" ]]; then
  bun add -D @types/node
else
  npm install -D @types/node
fi
cat <<EOT > vite.config.ts
import path from "path";
import react from "@vitejs/plugin-react";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
});
EOT

# Step 8: Initialize ShadCN
echo "Initializing ShadCN..."
if [[ "$package_manager" == "bun" ]]; then
  bunx --bun shadcn@latest init <<EOD
New York
Zinc
no
EOD
else
  npx shadcn@latest init <<EOD
New York
Zinc
no
EOD
fi

# Step 9: Add default components (e.g., Button)
echo "Adding ShadCN components..."
if [[ "$package_manager" == "bun" ]]; then
  bunx --bun shadcn@latest add button
else
  npx shadcn@latest add button
fi

echo "Setup complete! Navigate to your project directory and start coding 🚀"
