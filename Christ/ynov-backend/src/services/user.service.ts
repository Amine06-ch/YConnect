import { prisma } from "../lib/prisma";

export class UserService {
    static async getMe(userId: number) {
        const user = await prisma.user.findUnique({
            where: { id: userId },
            select: {
                id: true,
                email: true,
                firstName: true,
                lastName: true,
                bio: true,
                skills: true,
                createdAt: true,
            },
        });

        return user;
    }

    static async updateMe(
        userId: number,
        data: {
            firstName?: string;
            lastName?: string;
            bio?: string;
            skills?: string;
        }
    ) {
        const user = await prisma.user.update({
            where: { id: userId },
            data: {
                firstName: data.firstName,
                lastName: data.lastName,
                bio: data.bio,
                skills: data.skills,
            },
            select: {
                id: true,
                email: true,
                firstName: true,
                lastName: true,
                bio: true,
                skills: true,
                createdAt: true,
            },
        });

        return user;
    }
}