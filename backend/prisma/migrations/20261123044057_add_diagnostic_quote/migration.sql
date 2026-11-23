-- AlterTable
ALTER TABLE "ServiceRequest" ADD COLUMN     "diagnosticQuote" DOUBLE PRECISION,
ADD COLUMN     "inProgressAt" TIMESTAMP(3),
ADD COLUMN     "laborCost" DOUBLE PRECISION,
ADD COLUMN     "locationConsent" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "partsCost" DOUBLE PRECISION;
