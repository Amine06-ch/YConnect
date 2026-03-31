import { prisma } from "../lib/prisma";

export class MessageService {
    static async sendMessage(senderId: number, receiverId: number, content: string) {
        return prisma.message.create({
            data: {
                senderId,
                receiverId,
                content,
            },
            include: {
                sender: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                    },
                },
                receiver: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                    },
                },
            },
        });
    }

    static async getConversation(currentUserId: number, otherUserId: number) {
        return prisma.message.findMany({
            where: {
                OR: [
                    { senderId: currentUserId, receiverId: otherUserId },
                    { senderId: otherUserId, receiverId: currentUserId },
                ],
            },
            orderBy: {
                createdAt: "asc",
            },
            include: {
                sender: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                    },
                },
                receiver: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                    },
                },
            },
        });
    }

    static async getConversations(userId: number) {
        const messages = await prisma.message.findMany({
            where: {
                OR: [{ senderId: userId }, { receiverId: userId }],
            },
            orderBy: {
                createdAt: "desc",
            },
            include: {
                sender: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                    },
                },
                receiver: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                    },
                },
            },
        });

        const map = new Map<number, any>();

        for (const message of messages) {
            const otherUser =
                message.senderId === userId ? message.receiver : message.sender;

            if (!map.has(otherUser.id)) {
                map.set(otherUser.id, {
                    user: otherUser,
                    lastMessage: message.content,
                    createdAt: message.createdAt,
                });
            }
        }

        return Array.from(map.values());
    }
}