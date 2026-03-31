import { Response } from "express";
import { AuthRequest } from "../middlewares/auth.middleware";
import { UserService } from "../services/user.service";

export class UserController {
    static async getMe(req: AuthRequest, res: Response) {
        try {
            if (!req.user) {
                return res.status(401).json({
                    success: false,
                    message: "Utilisateur non authentifié",
                });
            }

            const user = await UserService.getMe(req.user.userId);

            return res.json({
                success: true,
                data: user,
            });
        } catch {
            return res.status(500).json({
                success: false,
                message: "Erreur lors de la récupération du profil",
            });
        }
    }

    static async updateMe(req: AuthRequest, res: Response) {
        try {
            if (!req.user) {
                return res.status(401).json({
                    success: false,
                    message: "Utilisateur non authentifié",
                });
            }

            const { firstName, lastName, bio, skills } = req.body;

            const user = await UserService.updateMe(req.user.userId, {
                firstName,
                lastName,
                bio,
                skills,
            });

            return res.json({
                success: true,
                data: user,
            });
        } catch {
            return res.status(500).json({
                success: false,
                message: "Erreur lors de la mise à jour du profil",
            });
        }
    }
}