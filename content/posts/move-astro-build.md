---
title: Write a blog with starlight.astro.build (and Nix)
date: 2024-06-02
draft: true
lastUpdated: 2024-06-14
description: How I configure my blog with starlight astro
tags: 
  - astro
  - nix
---

# Why change 
I have been terrible with writing. Making this blog is a way to practice my writing, but for the last 7 years, i didn't manage to squeeze out 10 posts, all the posts I did come with are ... not that good. Although no amount tailwind css, nextJS can fix that, maybe adapting a newer framework and a polish look of the site can give me a needed booster for give writing another try. Oh boy, starlight astro is polished. In this post, I want to share my experiences with starlight, hope it might help someone. 

# Starlight Componets 
Before starlight, I used hakyell. One thing I keep feel like  missing is [sidenote](https://tony-zorman.com/posts/block-sidenotes.html).

starlight offers lots of cool components for writing documentations:

https://starlight.astro.build/guides/components/
## Sidenote / Asides

:::tip
It’s best to avoid using `<blockquote>` for things that aren’t quotes.
:::

## Code Snippet
```js title="example.js" ins={3} del={2}
  function thisIsJavaScript() {
    console.log('Old code to be removed')
    console.log('New and shiny code!')
  }
```


:::caution[Deprecated]
Using `<blockquote>` for notes is deprecated.
:::


## Folder Tree
import { FileTree  } from '@astrojs/starlight/components';

<FileTree>
- public/
  - robots.txt
  - favicon.svg
  - social-image.png
- src/
  - components/
    - Header.astro
    - Button.jsx
  - layouts/
    - PostLayout.astro
  - pages/
    - posts/
      - post1.md
      - post2.md
      - post3.md
    - index.astro
  - styles/
    - global.css
- astro.config.mjs
- package.json
- tsconfig.json
</FileTree>

## Steps
import { Steps } from '@astrojs/starlight/components';

<Steps>

1. Import the component into your MDX file:

   ```js
   import { Steps } from '@astrojs/starlight/components';
   ```

2. Wrap `<Steps>` around your ordered list items.

</Steps>

## Badge

import { Badge } from '@astrojs/starlight/components';

<Badge text="New" variant="tip" size="small" />

<Badge text="Deprecated" variant="caution" size="medium" />

<Badge text="Starlight" variant="note" size="large" />

<Badge text="Custom" variant="success" style={{ fontStyle: 'italic' }} />

# Publish with Nix
I tried npm2nix and dream2nix to setup a local nix dev environment to beyond just provide nodejs, but 
# Conclusion

Here's a simple footnote,[^1] and here's a longer one.[^bignote]
[^1]: This is the first footnote.
[^bignote]: Here's one with multiple paragraphs and code.

    Indent paragraphs to include them in the footnote.

    `{ my code }`

    Add as many paragraphs as you like.
