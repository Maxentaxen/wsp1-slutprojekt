import { test, expect } from '@playwright/test';

test('has title', async ({ page }) => {
  await page.goto('localhost:9292'); // Öppnar sidan
  await page.getByLabel('Username').fill("Maxentaxen"); // Fyller i användarnamn och lösenord
  await page.getByLabel('Password').fill("Password123");

  await page.getByText('Log in').click(); // Trycker på knappen 


  await expect(page.getByText('FLIXMAX')).toBeVisible(); // Letar efter text
});

test('get started link', async ({ page }) => {
  await page.goto('https://playwright.dev/');

  // Click the get started link.
  await page.getByRole('link', { name: 'Get started' }).click();

  // Expects page to have a heading with the name of Installation.
  await expect(page.getByRole('heading', { name: 'Installation' })).toBeVisible();
});
