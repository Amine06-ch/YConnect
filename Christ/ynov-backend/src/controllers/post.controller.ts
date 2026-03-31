import { Response } from "express";
import { PostService } from "../services/post.service";
import { AuthRequest } from "../middlewares/auth.middleware";

export class PostController {
    static async getAll(req: AuthRequest, res: Response) {
        try {
            const posts = await PostService.getAllPosts();

            return res.json({
                success: true,
                data: posts,
            });
        } catch {
            return res.status(500).json({
                success: false,
                message: "Erreur lors de la récupération des posts",
            });
        }
    }

    static async create(req: AuthRequest, res: Response) {
        try {
            const { content } = req.body;

            if (!content || !content.trim()) {
                return res.status(400).json({
                    success: false,
                    message: "Le contenu du post est requis",
                });
            }

            if (!req.user) {
                return res.status(401).json({
                    success: false,
                    message: "Utilisateur non authentifié",
                });
            }

            const post = await PostService.createPost(content.trim(), req.user.userId);

            return res.status(201).json({
                success: true,
                data: post,
            });
        } catch {
            return res.status(500).json({
                success: false,
                message: "Erreur lors de la création du post",
            });
        }
    }

    static async delete(req: AuthRequest, res: Response) {
        try {
            const postId = Number(req.params.id);

            if (!req.user) {
                return res.status(401).json({
                    success: false,
                    message: "Utilisateur non authentifié",
                });
            }

            if (Number.isNaN(postId)) {
                return res.status(400).json({
                    success: false,
                    message: "ID du post invalide",
                });
            }

            await PostService.deletePost(postId, req.user.userId);

            return res.json({
                success: true,
                message: "Post supprimé",
            });
        } catch (error: any) {
            if (error.message === "POST_NOT_FOUND") {
                return res.status(404).json({
                    success: false,
                    message: "Post introuvable",
                });
            }

            if (error.message === "FORBIDDEN") {
                return res.status(403).json({
                    success: false,
                    message: "Tu ne peux supprimer que tes propres posts",
                });
            }

            return res.status(500).json({
                success: false,
                message: "Erreur lors de la suppression du post",
            });
        }
    }
}