import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
    const user = await prisma.user.create({
        data: {
            email: "lea@ynov.com",
            password: "hashedpassword",
            firstName: "Lea",
            lastName: "Martin",
            bio: "Étudiante dev",
            skills: "React, Node"
        }
    });

    await prisma.post.create({
        data: {
            content: "Hello Ynov 🚀",
            authorId: user.id
        }
    });

    console.log("Seed OK 🌱");
}

main()
    .catch(e => console.error(e))
    .finally(() => prisma.$disconnect());