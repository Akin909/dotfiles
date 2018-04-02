import * as React from "/Users/akinyulife/Desktop/Coding/oni/dist/mac/Oni.app/Contents/Resources/app/node_modules/react";
import * as Oni from "/Users/akinyulife/Desktop/Coding/oni/dist/mac/Oni.app/Contents/Resources/app/node_modules/oni-api";

export const activate = (oni: Oni.Plugin.Api) => {
    console.log("config activated");

    oni.input.unbind("<c-/>");
    oni.input.unbind("<m-d>");
    oni.input.unbind("<m-o>");
    oni.input.bind(["<enter>", "<tab>"], "contextMenu.select");
    oni.input.bind("<m-d>", "language.gotoDefinition");
    oni.input.bind("<m-\\>", "language.symbols.document");
    oni.input.bind("<m-r>", "language.rename");
    oni.input.bind("<m-/>", "quickOpen.showBufferLines");
    oni.input.bind("<m-,>", "commands.show");
    oni.input.bind("<m-;>", "markdown.togglePreview");
    oni.input.bind("<m-'>", "markdown.openPreview");
    oni.input.bind("<enter>", "contextMenu.select");
    oni.input.bind("<m-o>", "buffer.toggle");
    oni.input.bind("<c-d>", "buffer.delete");
    oni.input.bind("<c-s>", "buffer.split");
    oni.input.bind("<c-v>", "buffer.vsplit");
    oni.input.bind("<m-h>", "oni.editor.hide");
    oni.input.bind("<m-n>", "sidebar.toggle");
};

export const deactivate = (oni: Oni.Plugin.Api) => {
    console.log("config deactivated");
};

export const configuration = {
    //add custom config here, such as
    // UI customizations
    "ui.animations.enabled": true,
    "ui.fontSmoothing": "auto",

    // Font ------------------------------------
    // add custom config here, such as
    // Font alternatives "OperatorMono-XLight,

    // "editor.fontFamily": "FuraCode Nerd Font",
    // "editor.fontFamily": "FuraCodeNerdFontC-Light",
    // "editor.fontFamily": "HasklugNerdFontC-Light",
    // "editor.fontFamily": "OperatorMonoLig-Book",
    // "editor.fontFamily": "Hasklug Nerd Font",
    // "FiraCode-Medium"
    // OperatorMono-Light
    // Pragmata Pro"

    // 'ui.colorscheme': 'nord',
    // 'ui.colorscheme': 'solarized8_dark',

    // Debug -----------------------------------
    "debug.showNotificationOnError": true,

    // LSP -------------------------------------
    // "language.javascript.languageServer.command": "flow-language-server",
    // "language.javascript.languageServer.arguments": ["--stdio"],
    // "language.typescript.rootFiles": ["tsconfig.json", "package.json"],
    // "language.typescript.languageServer.command": "typescript-language-server",
    // "language.typescript.languageServer.arguments": ["--stdio"],

    "language.vue.languageServer.command": "vls",

    "language.go.languageServer.command": "go-langserver",
    "language.go.languageServer.arguments": ["--gocodecompletion", "--freeosmemory", "false"],
    // "language.go.languageServer.rootFiles": [".git"],

    // Experimental -----------------------------
    "markdownPreview.enabled": true,
    "experimental.welcome.enabled": false,

    // Oni Core ---------------------------------
    "oni.bookmarks": ["~/Dotfiles", "~/Desktop/Coding/Work"],
    "oni.useDefaultConfig": false,
    "oni.loadInitVim": true,
    // Editor -----------------------------------

    "editor.fontFamily": "FiraCode-Retina",
    // "editor.fontFamily": "OperatorMonoLig-Medium",
    // "editor.fontFamily": "Hasklig-Regular",
    // "editor.fontFamily": "DejaVuSansCode",
    "editor.fontSize": "17px",
    "editor.cursorLine": true,
    "editor.scrollBar.visible": true,
    "experimental.particles.enabled": false,
    // UI ---------------------------------------
    // "ui.fontFamily": "OperatorMono-Medium",
    "ui.fontFamily": "FiraCode-Medium",
    "ui.fontSize": "16px",
    "ui.colorscheme": "onedark",
    "tabs.mode": "buffers",

    // Workspace ---------------------------------------
    "workspace.autoDetectWorkspace": "always",

    // Plugins ---------------------------------------
    "oni.plugins.prettier": {
        settings: {
            semi: true,
            tabWidth: 4,
            useTabs: false,
            singleQuote: false,
            trailingComma: "all",
            bracketSpacing: true,
            jsxBracketSameLine: false,
            arrowParens: "avoid",
            printWidth: 100,
        },
        formatOnSave: true,
        enabled: true,
    },
};
