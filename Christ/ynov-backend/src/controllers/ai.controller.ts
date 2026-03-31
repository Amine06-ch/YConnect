import { Request, Response } from "express";
import { AIService } from "../services/ai.service";

export class AIController {
    static async chat(req: Request, res: Response) {
        try {
            const { message } = req.body;

            if (!message || !message.trim()) {
                return res.status(400).json({
                    success: false,
                    message: "Le message est requis",
                });
            }

            const reply = await AIService.chat(message.trim());

            return res.json({
                success: true,
                data: {
                    reply,
                },
            });
        } catch (error: any) {
            if (error.message === "NO_GEMINI_KEY") {
                return res.status(500).json({
                    success: false,
                    message: "Clé Gemini manquante",
                });
            }

            return res.status(500).json({
                success: false,
                message: "Erreur IA",
            });
        }
    }
}