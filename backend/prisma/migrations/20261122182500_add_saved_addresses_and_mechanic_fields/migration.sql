-- AlterTable
ALTER TABLE "MechanicProfile" ADD COLUMN "bio" TEXT,
ADD COLUMN "certifications" TEXT[] DEFAULT ARRAY[]::TEXT[],
ADD COLUMN "specializations" TEXT[] DEFAULT ARRAY[]::TEXT[],
ADD COLUMN "workshopAddress" TEXT;

-- CreateTable
CREATE TABLE "SavedAddress" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "label" TEXT NOT NULL,
    "address" TEXT NOT NULL,
    "latitude" DOUBLE PRECISION,
    "longitude" DOUBLE PRECISION,
    "isDefault" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SavedAddress_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "SavedAddress_userId_idx" ON "SavedAddress"("userId");

-- AddForeignKey
ALTER TABLE "SavedAddress" ADD CONSTRAINT "SavedAddress_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
