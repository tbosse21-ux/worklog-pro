import '../database/customer_repository.dart';
import '../database/work_report_repository.dart';
import '../models/company.dart';
import '../models/customer.dart';
import '../models/work_report.dart';
import '../repositories/company_repository.dart';

class PdfData {
  final Company company;
  final Customer customer;
  final WorkReport report;

  PdfData({
    required this.company,
    required this.customer,
    required this.report,
  });
}

class PdfDataService {
  static Future<PdfData?> load(
    int reportId,
  ) async {
    final companyRepository =
        CompanyRepository();

    final workReportRepository =
        WorkReportRepository();

    final customerRepository =
        CustomerRepository();

    final report =
        await workReportRepository.getById(
      reportId,
    );

    if (report == null) return null;

    final customer =
        await customerRepository.getCustomerById(
      report.customerId,
    );

    if (customer == null) return null;

    final company =
        await companyRepository.load();

    if (company == null) return null;

    return PdfData(
      company: company,
      customer: customer,
      report: report,
    );
  }
}