import '../database/customer_repository.dart';
import '../database/material_repository.dart';
import '../database/work_report_material_repository.dart';
import '../database/work_report_repository.dart';
import '../models/company.dart';
import '../models/customer.dart';
import '../models/material_item.dart';
import '../models/work_report.dart';
import '../models/work_report_material.dart';
import '../repositories/company_repository.dart';

class PdfData {
  final Company company;
  final Customer customer;
  final WorkReport report;

  final List<WorkReportMaterial> materials;
  final Map<int, MaterialItem> materialCatalog;

  PdfData({
    required this.company,
    required this.customer,
    required this.report,
    required this.materials,
    required this.materialCatalog,
  });
}

class PdfDataService {
  static Future<PdfData?> load(int reportId) async {
    final companyRepository = CompanyRepository();

    final workReportRepository = WorkReportRepository();

    final customerRepository = CustomerRepository();

    final workReportMaterialRepository =
        WorkReportMaterialRepository();

    final materialRepository = MaterialRepository();

    final report =
        await workReportRepository.getById(reportId);

    if (report == null) return null;

    final customer =
        await customerRepository.getCustomerById(
      report.customerId,
    );

    if (customer == null) return null;

    final company = await companyRepository.load();

    if (company == null) return null;

    final materials =
        await workReportMaterialRepository.getByReport(
      report.id!,
    );

    final Map<int, MaterialItem> materialCatalog = {};

    for (final item in materials) {
      final material =
          await materialRepository.getById(
        item.materialId,
      );

      if (material != null) {
        materialCatalog[item.materialId] = material;
      }
    }

    return PdfData(
      company: company,
      customer: customer,
      report: report,
      materials: materials,
      materialCatalog: materialCatalog,
    );
  }
}