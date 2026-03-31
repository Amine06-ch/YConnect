import { Router } from "express";
import { authMiddleware } from "../middlewares/auth.middleware";
import { MessageController } from "../controllers/message.controller";

const router = Router();

router.get("/conversations", authMiddleware, MessageController.getConversations);
router.get("/:userId", authMiddleware, MessageController.getConversation);
router.post("/", authMiddleware, MessageController.send);

export default router;