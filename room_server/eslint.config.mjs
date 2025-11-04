import js from "@eslint/js";
import jsdoc from 'eslint-plugin-jsdoc';
import { defineConfig } from "eslint/config";
import globals from "globals";

export default defineConfig([
  { files: ["**/*.{js,mjs,cjs}"],
    plugins: {
      js,
      jsdoc
    },
    extends: ["js/recommended"],
    languageOptions: { globals: globals.node },
    rules: {
      "no-console": "warn",
      "prefer-const": "error",
      "jsdoc/require-jsdoc": [ "error", {
        "require": {
          "FunctionDeclaration": true,
          "MethodDefinition": true,
          "ClassDeclaration": true,
          "ArrowFunctionExpression": true,
          "FunctionExpression": true
        }
      }],
      "jsdoc/require-param": "error",
      "jsdoc/require-param-type": "error",
      "jsdoc/require-returns": "error",
      "jsdoc/require-returns-type": "error",
      "jsdoc/require-description": "error"
    }
  },
  { files: ["**/*.js"],
    languageOptions: { sourceType: "commonjs" }
  },
  ]);
