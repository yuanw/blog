import { defineConfig } from 'astro/config';
import mdx from '@astrojs/mdx';
import org from 'astro-org';
import sitemap from '@astrojs/sitemap';

import starlight from "@astrojs/starlight";

// https://astro.build/config
export default defineConfig({
  site: 'https://example.com',
  integrations: [org(), mdx(), sitemap(), starlight()]
});