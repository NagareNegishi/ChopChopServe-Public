Test linting with javaScript code.
To avoid affecting others

## Select a linting tool

my option is:

- JSLint
- JSHint
- JSCS
- ESLint

I will chose ESLint because it is widely used and highly configurable.
https://www.sitepoint.com/comparison-javascript-linting-tools/

[ESLint adoption guide](https://blog.logrocket.com/eslint-adoption-guide/)

[Linting in TypeScript](https://blog.logrocket.com/linting-typescript-eslint-prettier/)

Step:
1. Move to the directory where your JavaScript files are located.
2. install ESLint with modern way:
   ```bash
   npm init @eslint/config@latest
   ```
3. it will ask you a series of questions to set up your configuration -> create setting file `eslint.config.mjs`
4. add lint script to `package.json`:
   ```json
    "scripts": {
    "start": "node server.js",
    "lint": "eslint .",
    //"lint:fix": "eslint . --fix"
    }
   ```
    `"lint": "eslint ."` will check all files in the current directory, but not fix them.
    `"lint:fix": "eslint . --fix"` will check all files in the current directory and fix any fixable issues.
    To avoid unexpected changes, first test with `"lint": "eslint ."` only.
5. Run the linter to see if there are any issues:
   ```bash
   npm run lint
   ```
6. Add JSDoc plugin:
   ```bash
   npm install --save-dev eslint-plugin-jsdoc
   ```
   Note: ESLint provide "core rules" by default. But to enforce specific coding styles, I need to install additional plugins. While I should learn TypeScript in the future, for now I will start with JSDoc.
7. Update `eslint.config.mjs` to include JSDoc plugin by adding:
   ```javascript
   import jsdoc from 'eslint-plugin-jsdoc';
   ```
   and new rules:
   ```javascript
    export default defineConfig([
    {
        files: ["**/*.{js,mjs,cjs}"],
        plugins: {
        js,
        jsdoc  // include jsdoc plugin
        },
        extends: ["js/recommended"],
        languageOptions: { globals: globals.node },
        rules: {  // add custom rules here
        // JSDoc rules
        "jsdoc/require-jsdoc": ["error", {
            require: {
            "FunctionDeclaration": true, // All functions must have JSDoc comments
            "MethodDefinition": true, // All methods must have JSDoc comments
            "ClassDeclaration": true, // All classes must have JSDoc comments
            // Since I use modern JavaScript, I will also enforce JSDoc for function expressions and arrow functions
            "FunctionExpression": true,         // For const f = function() { }
            "ArrowFunctionExpression": true,    // For const f = () => { }
            }
        }],
        // Additional JSDoc rules to enforce documentation quality
        "jsdoc/require-param": "error", // Ensure all parameters are documented
        "jsdoc/require-param-type": "error", // Ensure parameter types are specified
        "jsdoc/require-returns": "error", // Ensure return values are documented
        "jsdoc/require-returns-type": "error", // Ensure return types are specified
        "jsdoc/require-description": "error" // Ensure descriptions are provided
        }
    },
    { files: ["**/*.js"], languageOptions: { sourceType: "commonjs" } },
    ]);
    ```
