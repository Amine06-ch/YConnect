import { prisma } from "../lib/prisma";

export class PostService {
    static async getAllPosts() {
        const posts = await prisma.post.findMany({
            include: {
                author: {
                    select: {
                        id: true,
                        email: true,
                        firstName: true,
                        lastName: true,
                    },
                },
            },
            orderBy: {
                createdAt: "desc",
            },
        });

        return posts;
    }

    static async createPost(content: string, authorId: number) {
        const post = await prisma.post.create({
            data: {
                content,
                authorId,
            },
            include: {
                author: {
                    select: {
                        id: true,
                        email: true,
                        firstName: true,
                        lastName: true,
                    },
                },
            },
        });

        return post;
    }

    static async deletePost(postId: number, userId: number) {
        const post = await prisma.post.findUnique({
            where: { id: postId },
        });

        if (!post) {
            throw new Error("POST_NOT_FOUND");
        }

        if (post.authorId !== userId) {
            throw new Error("FORBIDDEN");
        }

        await prisma.post.delete({
            where: { id: postId },
        });

        return true;
    }
}