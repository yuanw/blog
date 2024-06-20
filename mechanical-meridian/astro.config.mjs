import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import starlightBlog from 'starlight-blog';

// https://astro.build/config
export default defineConfig({
    site: 'https://yuanwang.ca',
	integrations: [
		starlight({
			title: 'Yuan Wang',
            credits: true,
            plugins: [starlightBlog(
                prefix: 'posts',
            )],
            // components: {
            //    Footer: './src/components/Footer.astro'
            //},

			social: {
				github: 'https://github.com/yuanw/blog',
			},
			sidebar: [
				{
					label: 'Guides',
					items: [
						// Each item here is one entry in the navigation menu.
						{ label: 'Example Guide', link: '/guides/example/' },
					],
				},
				{
					label: 'Reference',
					autogenerate: { directory: 'reference' },
				},
			],
		}),
	],
});
