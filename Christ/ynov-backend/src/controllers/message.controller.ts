import { Response } from "express";
import { AuthRequest } from "../middlewares/auth.middleware";
import { MessageService } from "../services/message.service";

export class MessageController {
    static async send(req: AuthRequest, res: Response) {
        try {
            if (!req.user) {
                return res.status(401).json({
                    success: false,
                    message: "Utilisateur non authentifié",
                });
            }

            const { receiverId, content } = req.body;

            if (!receiverId || !content || !content.trim()) {
                return res.status(400).json({
                    success: false,
                    message: "receiverId et content sont requis",
                });
            }

            const message = await MessageService.sendMessage(
                req.user.userId,
                Number(receiverId),
                content.trim()
            );

            return res.status(201).json({
                success: true,
                data: message,
            });
        } catch {
            return res.status(500).json({
                success: false,
                message: "Erreur lors de l'envoi du message",
            });
        }
    }

    static async getConversation(req: AuthRequest, res: Response) {
        try {
            if (!req.user) {
                return res.status(401).json({
                    success: false,
                    message: "Utilisateur non authentifié",
                });
            }

            const otherUserId = Number(req.params.userId);

            const messages = await MessageService.getConversation(
                req.user.userId,
                otherUserId
            );

            return res.json({
                success: true,
                data: messages,
            });
        } catch {
            return res.status(500).json({
                success: false,
                message: "Erreur lors de la récupération des messages",
            });
        }
    }

    static async getConversations(req: AuthRequest, res: Response) {
        try {
            if (!req.user) {
                return res.status(401).json({
                    success: false,
                    message: "Utilisateur non authentifié",
                });
            }

            const conversations = await MessageService.getConversations(req.user.userId);

            return res.json({
                success: true,
                data: conversations,
            });
        } catch {
            return res.status(500).json({
                success: false,
                message: "Erreur lors de la récupération des conversations",
            });
        }
    }
}