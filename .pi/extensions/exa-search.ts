/**
 * Exa Web Search tool for pi
 *
 * Reads API key from 1Password CLI:
 *   op read "${EXA_OP_REFERENCE:-op://Private/API-Keys/EXA_API_KEY}"
 */

import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { Type } from "@mariozechner/pi-ai";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const execFileAsync = promisify(execFile);

type ExaResult = {
	title?: string;
	url?: string;
	highlights?: string[];
	publishedDate?: string;
};

async function readExaApiKeyFrom1Password(): Promise<string> {
	const reference =
		process.env.EXA_OP_REFERENCE ?? "op://Private/API-Keys/EXA_API_KEY";

	const { stdout } = await execFileAsync("op", ["read", reference]);
	const key = stdout.trim();
	if (!key) throw new Error("1Password returned an empty EXA API key");
	return key;
}

export default function (pi: ExtensionAPI) {
	pi.registerTool({
		name: "web_search_exa",
		label: "Exa Web Search",
		description:
			"Search the web with Exa (type=auto) and return compact highlighted snippets.",
		parameters: Type.Object({
			query: Type.String({ description: "Search query" }),
			num_results: Type.Optional(
				Type.Number({ description: "Number of results (default: 8)" }),
			),
			max_characters: Type.Optional(
				Type.Number({
					description: "Max highlight characters (default: 2000)",
				}),
			),
		}),

		async execute(_toolCallId, params) {
			const {
				query,
				num_results = 8,
				max_characters = 2000,
			} = params as {
				query: string;
				num_results?: number;
				max_characters?: number;
			};

			let apiKey: string;
			try {
				apiKey = await readExaApiKeyFrom1Password();
			} catch (error) {
				return {
					content: [
						{
							type: "text",
							text: `Unable to read Exa API key from 1Password CLI (op). ${String(error)}`,
						},
					],
					details: { ok: false, reason: "missing_api_key" },
				};
			}

			const response = await fetch("https://api.exa.ai/search", {
				method: "POST",
				headers: {
					"x-api-key": apiKey,
					"content-type": "application/json",
				},
				body: JSON.stringify({
					query,
					type: "auto",
					num_results,
					contents: {
						highlights: {
							max_characters,
						},
					},
				}),
			});

			if (!response.ok) {
				const errorText = await response.text();
				return {
					content: [
						{
							type: "text",
							text: `Exa API error (${response.status}): ${errorText}`,
						},
					],
					details: {
						ok: false,
						reason: "http_error",
						status: response.status,
					},
				};
			}

			const data = (await response.json()) as { results?: ExaResult[] };
			const results = data.results ?? [];

			const output = results
				.map((r, i) => {
					const title = r.title ?? "(untitled)";
					const url = r.url ?? "";
					const date = r.publishedDate ? `\nPublished: ${r.publishedDate}` : "";
					const snippet =
						r.highlights && r.highlights.length > 0
							? `\nSnippet: ${r.highlights[0]}`
							: "";
					return `${i + 1}. ${title}\n${url}${date}${snippet}`;
				})
				.join("\n\n");

			return {
				content: [
					{
						type: "text",
						text: output || "No results.",
					},
				],
				details: {
					ok: true,
					count: results.length,
					query,
					num_results,
					type: "auto",
					content_mode: "highlights",
				},
			};
		},
	});
}
