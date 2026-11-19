# Create an invoice

A user creates an invoice for a customer, sees it in the invoice list, and can cancel an unfinished
draft without saving it.

## Sub-features

- `invoice-open`: opens an empty form from each entry point.
- `invoice-save`: stores a customer, an amount, and a due date.
- `invoice-invalid`: rejects an invoice without an amount.
- `invoice-cancel`: discards an unfinished draft.

## How to reach it

- Choose the `New invoice` button on the `/invoices` page.
- Choose `Create invoice` on a customer's page, for example `/customers/acme`.

## How to drive it

Preconditions:

- The doctor check passes.
- You are logged in as `owner@ledger.test`.
- `Acme` has no invoice of 1,250.00.

Steps:

- **Open the form.** Choose `New invoice`. The URL becomes `/invoices/new`, and the heading reads
  `New invoice`. Run:
  `page.getByRole('button', { name: 'New invoice' }).click()`
- **Reject an empty amount.** Choose `Save invoice` with no amount. The text `Amount can't be blank`
  appears, and the URL does not change. Run:
  `page.getByRole('button', { name: 'Save invoice' }).click()`
- **Enter the invoice.** Pick the customer and type the amount. Run
  `page.getByLabel('Customer').selectOption('Acme')` and `page.getByLabel('Amount').fill('1250')`.
- **Save.** Choose `Save invoice`. The URL matches `/invoices/<id>`, and the heading shows `Acme`
  and `1,250.00`.
- **Confirm that it is stored.** Open `/invoices`. The list has a row with `Acme` and `1,250.00`.
  Then run `curl -s localhost:3000/api/invoices?customer=acme`. The response holds one invoice with
  `"amount_cents": 125000`.
- **Cancel a draft.** Open the form again, type `999` as the amount, and choose `Cancel`. The list
  returns and has no row with `999.00`.
- **Second entry point.** Open `/customers/acme` and choose `Create invoice`. The form opens with
  `Acme` already selected.
- **Proof.** Take a screenshot of the saved invoice and of the list. Save the output of the
  `curl` command next to them.

## Gotchas

- The amount field takes whole currency units and stores cents. Assert the formatted value on the
  page, not the value that you typed.
- The success message is a toast that disappears. Assert the heading of the saved invoice, not the
  toast.
- A redirect to the invoice page alone does not prove the save. Check the list and the row count.
- Delete the invoice during cleanup, and keep the screenshots.
