# Finance Module

This module handles bank account management for astrologers.

## Features

- Add bank accounts with required details
- View list of bank accounts
- Upload passbook documents (optional)
- Form validation for all fields

## API Integration

The module integrates with the following API endpoint:
- **POST** `/astrologer/bank-accounts` - Add new bank account
- **GET** `/astrologer/bank-accounts` - Get list of bank accounts

## Usage

### Navigation
```dart
// Navigate to bank accounts list
Get.toNamed('/bank-accounts');

// Navigate to add bank account form
Get.toNamed('/add-bank-account');
```

### Testing
Use the test screen to quickly access finance features:
```dart
Get.toNamed('/test-finance');
```

## Architecture

The module follows clean architecture with:

- **Domain Layer**: Models, repository interfaces, use cases
- **Data Layer**: Repository implementation, data sources
- **Presentation Layer**: Controllers, screens, bindings

## Files Structure

```
lib/features/finance/
├── domain/
│   ├── models/
│   │   └── bank_account_model.dart
│   ├── repositories/
│   │   └── finance_repository_interface.dart
│   └── usecases/
│       ├── add_bank_account_usecase.dart
│       └── get_bank_accounts_usecase.dart
├── data/
│   ├── datasources/
│   │   └── finance_remote_data_source.dart
│   └── repositories/
│       └── finance_repository.dart
└── presentation/
    ├── controllers/
    │   └── finance_controller.dart
    ├── screens/
    │   ├── bank_accounts_screen.dart
    │   └── add_bank_account_screen.dart
    └── bindings/
        └── finance_binding.dart
```

## API Response Format

### Add Bank Account Response
```json
{
  "status": "success",
  "message": "Bank account added successfully.",
  "data": {
    "bank_account": {
      "id": 1,
      "astrologer_id": 2,
      "account_holder_name": "John Doe",
      "bank_name": "HDFC Bank",
      "account_number": "123456789012",
      "ifsc_code": "HDFC0001234",
      "passbook_document": null,
      "is_default": true,
      "is_active": true,
      "created_at": "2026-03-30T12:30:18.000000Z",
      "updated_at": "2026-03-30T12:30:18.000000Z"
    }
  }
}
```