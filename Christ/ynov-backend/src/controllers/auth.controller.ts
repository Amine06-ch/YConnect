import { Request, Response } from "express";
import { AuthService } from "../services/auth.service";

export class AuthController {
    static async register(req: Request, res: Response) {
        try {
            const { email, password, firstName, lastName } = req.body;

            if (!email || !password) {
                return res.status(400).json({
                    success: false,
                    message: "Email et mot de passe requis",
                });
            }

            const user = await AuthService.register({
                email,
                password,
                firstName,
                lastName,
            });

            return res.status(201).json({
                success: true,
                data: user,
            });
        } catch (error: any) {
            if (error.message === "EMAIL_ALREADY_EXISTS") {
                return res.status(409).json({
                    success: false,
                    message: "Cet email existe déjà",
                });
            }

            return res.status(500).json({
                success: false,
                message: "Erreur lors de l'inscription",
            });
        }
    }

    static async login(req: Request, res: Response) {
        try {
            const { email, password } = req.body;

            if (!email || !password) {
                return res.status(400).json({
                    success: false,
                    message: "Email et mot de passe requis",
                });
            }

            const result = await AuthService.login(email, password);

            return res.json({
                success: true,
                data: result,
            });
        } catch (error: any) {
            if (error.message === "INVALID_CREDENTIALS") {
                return res.status(401).json({
                    success: false,
                    message: "Identifiants invalides",
                });
            }

            return res.status(500).json({
                success: false,
                message: "Erreur lors de la connexion",
            });
        }
    }
}