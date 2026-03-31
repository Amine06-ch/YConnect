import { Router } from "express";
import { authMiddleware } from "../middlewares/auth.middleware";
import { UserController } from "../controllers/user.controller";

const router = Router();

router.get("/me", authMiddleware, UserController.getMe);
router.put("/me", authMiddleware, UserController.updateMe);

export default router;