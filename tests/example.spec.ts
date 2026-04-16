import { test, expect } from '@playwright/test';

test('has title', async ({ page }) => {
  await page.goto('localhost:9292');
  await page.getByLabel('Username').fill("Maxentaxen");
  await page.getByLabel('Password').fill("Password123");

  await page.getByText('Log in').click()


  // Expect a title "to contain" a substring.
  await expect(page.getByText('FLIXMAX')).toBeVisible();
});

test('get started link', async ({ page }) => {
  await page.goto('https://playwright.dev/');

  // Click the get started link.
  await page.getByRole('link', { name: 'Get started' }).click();

  // Expects page to have a heading with the name of Installation.
  await expect(page.getByRole('heading', { name: 'Installation' })).toBeVisible();
});
