const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function resetTestFixtures() {
  console.log('>>> [FIXTURE RESET] Cleaning active test service requests and resetting locations...');
  
  // Set all incomplete service requests to COMPLETED
  const srResult = await prisma.serviceRequest.updateMany({
    where: {
      currentStatus: { in: ['ACCEPTED', 'EN_ROUTE', 'ARRIVED', 'IN_PROGRESS'] }
    },
    data: {
      currentStatus: 'COMPLETED',
      completedAt: new Date()
    }
  });

  // Reset all mechanic profiles to AVAILABLE
  const mpResult = await prisma.mechanicProfile.updateMany({
    data: {
      availabilityStatus: 'AVAILABLE'
    }
  });

  // Ensure Apex mechanic (Alex) is positioned at standard Downtown NYC baseline (40.7128, -74.0060)
  const alexProfile = await prisma.mechanicProfile.findFirst({
    where: { workshopName: { contains: 'Apex' } }
  });

  if (alexProfile) {
    await prisma.mechanicLocation.upsert({
      where: { mechanicId: alexProfile.id },
      update: { latitude: 40.7128, longitude: -74.0060, accuracy: 5.0 },
      create: { mechanicId: alexProfile.id, latitude: 40.7128, longitude: -74.0060, accuracy: 5.0 }
    });
  }

  console.log(`    ✓ Cleaned ${srResult.count} active requests, restored ${mpResult.count} mechanics to AVAILABLE.`);
  console.log('    ✓ Baseline NYC coordinates (40.7128, -74.0060) confirmed.');
}

resetTestFixtures()
  .catch((err) => {
    console.error('Fixture reset failed:', err);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
