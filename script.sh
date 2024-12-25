#!/bin/bash

# Check if bun or npm is installed
if ! command -v bun &> /dev/null && ! command -v npm &> /dev/null; then
  echo "Neither Bun nor NPM is installed. Please install one of them to proceed."
  exit 1
fi

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

echo "Installing @radix-ui/react-icons..."
if [[ "$package_manager" == "bun" ]]; then
  bun add @radix-ui/react-icons
else
  npm install @radix-ui/react-icons
fi

# Ensure src directory exists
mkdir -p src

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
mkdir -p src/components/ui
cat <<EOT > src/components/ui/button.tsx
import * as React from "react"
import { Slot } from "@radix-ui/react-slot"
import { cva, type VariantProps } from "class-variance-authority"

import { cn } from "@/lib/utils"

const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0",
  {
    variants: {
      variant: {
        default:
          "bg-primary text-primary-foreground shadow hover:bg-primary/90",
        destructive:
          "bg-destructive text-destructive-foreground shadow-sm hover:bg-destructive/90",
        outline:
          "border border-input bg-background shadow-sm hover:bg-accent hover:text-accent-foreground",
        secondary:
          "bg-secondary text-secondary-foreground shadow-sm hover:bg-secondary/80",
        ghost: "hover:bg-accent hover:text-accent-foreground",
        link: "text-primary underline-offset-4 hover:underline",
      },
      size: {
        default: "h-9 px-4 py-2",
        sm: "h-8 rounded-md px-3 text-xs",
        lg: "h-10 rounded-md px-8",
        icon: "h-9 w-9",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
)

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : "button"
    return (
      <Comp
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    )
  }
)
Button.displayName = "Button"

export { Button, buttonVariants }
EOT

cat <<EOT > src/App.tsx

import { Button } from "./components/ui/button";
import { GitHubLogoIcon, StarFilledIcon } from "@radix-ui/react-icons";
import { ChevronRightIcon } from "@radix-ui/react-icons";
const App = () => {
  return (
    <div className="flex flex-col items-center justify-center h-screen">
      <h1 className="text-4xl font-bold tracking-tighter sm:text-5xl md:text-6xl">Vite project generated using automation!</h1>
      <p className="font-normal text-center mt-4 text-xl text-muted-foreground">If you found this script helpful make sure to star the repo and follow the developer.</p>
      <div className="flex mt-6 gap-10">
       
        <Button>
          <a
            href="https://github.com/zaid-commits/vite-shadcn-automation"
            target="_blank"
            className="flex items-center"
          >
            <StarFilledIcon className="mr-2 h-4 w-4 text-yellow-500" />
            Star the repo
          </a>
          <ChevronRightIcon className="mr-2 h-4 w-4" />
        </Button>

        <Button variant={"outline"}>
          <a
            href="https://github.com/zaid-commits/"
            target="_blank"
            className="flex items-center"
          >
            <GitHubLogoIcon className="mr-2 h-4 w-4 text-black" />
            Follow Developer
          </a>
          <ChevronRightIcon className="mr-2 h-4 w-4" />
        </Button>
      </div>
    </div>
  );
};

export default App;

EOT

# completion message
echo -e "\e[32m🎉 Setup complete! All dependencies are installed, and the app is ready to go!\e[0m"

read -p "Do you want to initialize a git repo in this project? (yes/no): " init_git

if [[ "$init_git" == "yes" ]]; then
  git init
  git add .
  git commit -m "Initial commit"
  echo -e "\e[32mGit repository initialized and initial commit made.\e[0m"
else
  echo -e "\e[33mSkipping git initialization.\e[0m"
fi

echo -e "\e[34mRun \`$package_manager run dev\` to start your development server.\e[0m"
echo -e "\e[36m🚀 Enjoy coding and happy building!\e[0m"
