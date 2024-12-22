

# enter project name
read -p "Enter the name of your project: " project_name

# select package manager
read -p "Do you want to use Bun or NPM? (bun/npm): " package_manager

if [[ "$package_manager" != "bun" && "$package_manager" != "npm" ]]; then
  echo "Invalid choice. Please choose 'bun' or 'npm'."
  exit 1
fi

# new vite project
echo "Creating a new Vite project..."
if [[ "$package_manager" == "bun" ]]; then
  bun create vite@latest "$project_name" --template react-ts
else
  npx create-vite@latest "$project_name" --template react-ts
fi
cd "$project_name" || exit

# tailwind dependencies
echo "Installing Tailwind CSS..."
if [[ "$package_manager" == "bun" ]]; then
  bun add -D tailwindcss postcss autoprefixer
  bunx --bun tailwindcss init -p
else
  npm install -D tailwindcss postcss autoprefixer
  npx tailwindcss init -p
fi

# tailwind config
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

# Tailwind imports and inter font
echo "@import url('https://fonts.googleapis.com/css2?family=Inter:ital,opsz,wght@0,14..32,100..900;1,14..32,100..900&display=swap');" > src/index.css
echo "@tailwind base;" >> src/index.css
echo "@tailwind components;" >> src/index.css
echo "@tailwind utilities;" >> src/index.css
echo "body { font-family: 'Inter'; }" >> src/index.css
echo "body { font-weight: 500; }" >> src/index.css

# Step 4: Install TailwindCSS plugins (tailwindcss-animate)
echo "Installing TailwindCSS plugins (tailwindcss-animate)..."
if [[ "$package_manager" == "bun" ]]; then
  bun add -D tailwindcss-animate
else
  npm install -D tailwindcss-animate
fi

#tsconfig.json
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

#tsconfig.app.json
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

# vite.config.ts
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

#  ShadCN
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

# shadcn button
echo "Adding ShadCN components..."
if [[ "$package_manager" == "bun" ]]; then
  bunx --bun shadcn@latest add button
else
  npx shadcn@latest add button
fi

# promotion
echo "Adding promotion message to App.tsx..."
cat <<EOT > src/App.tsx
import React from "react";

const App = () => {
  return (
    <div>
      <div
        style={{
          backgroundColor: "#e0f7fa",
          color: "#00796b",
          padding: "20px",
          margin: "20px 0",
          borderRadius: "10px",
          textAlign: "center",
          fontSize: "16px",
        }}
      >
        <p>
          🎉 This script was writter by <strong>Zaid</strong>! 
          Check out the code on my{" "}
          <a href="https://github.com/zaid-commits" target="_blank" rel="noopener noreferrer">
            GitHub
          </a>
          . Don't forget to star the <a href="https://github.com/zaid-commits/vite-shadcn-automation">repo</a> and show your support! 🌟
        </p>
      </div>
    </div>
  );
};

export default App;
EOT

# completion message
echo -e "\e[32m🎉 Setup complete! All dependencies are installed, and the app is ready to go!\e[0m"
echo -e "\e[34mRun \`$package_manager run dev\` to start your development server.\e[0m"
echo -e "\e[36m🚀 Enjoy coding and happy building!\e[0m"
