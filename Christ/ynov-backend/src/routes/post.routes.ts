import { Router } from "express";
import { PostController } from "../controllers/post.controller";
import { authMiddleware } from "../middlewares/auth.middleware";

const router = Router();

router.get("/", PostController.getAll);
router.post("/", authMiddleware, PostController.create);
router.delete("/:id", authMiddleware, PostController.delete);

export default router;