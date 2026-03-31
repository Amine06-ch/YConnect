import { GoogleGenerativeAI } from "@google/generative-ai";

export class AIService {
    static async chat(message: string) {
        const apiKey = process.env.GEMINI_API_KEY;

        console.log("GEMINI_API_KEY loaded:", !!apiKey);

        if (!apiKey) {
            throw new Error("NO_GEMINI_KEY");
        }

        try {
            const genAI = new GoogleGenerativeAI(apiKey);
            const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

            const prompt = `
Tu es l'assistant IA de YConnect, un réseau social étudiant pour Paris Ynov Campus.
Tu aides sur :
- profil étudiant
- projets
- design
- alternance / stage
- vie de campus

Réponds en français, de façon courte, utile et claire.

Question utilisateur :
${message}
`;

            const result = await model.generateContent(prompt);
            const response = await result.response;
            const text = response.text();

            console.log("Gemini reply OK");
            return text;
        } catch (error) {
            console.error("GEMINI ERROR:", error);
            throw error;
        }
    }
}