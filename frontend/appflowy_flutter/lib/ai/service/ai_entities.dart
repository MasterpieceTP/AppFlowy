import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/generated/locale_keys.g.dart';
import 'package:appflowy_backend/protobuf/flowy-ai/protobuf.dart';
import 'package:appflowy_backend/protobuf/flowy-database2/protobuf.dart';
import 'package:appflowy_backend/protobuf/flowy-folder/protobuf.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ai_entities.g.dart';

class AIStreamEventPrefix {
  static const data = 'data:';
  static const error = 'error:';
  static const metadata = 'metadata:';
  static const start = 'start:';
  static const finish = 'finish:';
  static const comment = 'comment:';
  static const aiResponseLimit = 'ai_response_limit:';
  static const aiImageResponseLimit = 'ai_image_response_limit:';
  static const aiMaxRequired = 'ai_max_required:';
  static const localAINotReady = 'local_ai_not_ready:';
  static const localAIDisabled = 'local_ai_disabled:';
  static const aiFollowUp = 'ai_follow_up:';
}

enum AiType {
  cloud,
  local;

  bool get isCloud => this == cloud;
  bool get isLocal => this == local;
}

class PredefinedFormat extends Equatable {
  const PredefinedFormat({
    required this.imageFormat,
    required this.textFormat,
  });

  final ImageFormat imageFormat;
  final TextFormat? textFormat;

  PredefinedFormatPB toPB() {
    return PredefinedFormatPB(
      imageFormat: switch (imageFormat) {
        ImageFormat.text => ResponseImageFormatPB.TextOnly,
        ImageFormat.image => ResponseImageFormatPB.ImageOnly,
        ImageFormat.textAndImage => ResponseImageFormatPB.TextAndImage,
      },
      textFormat: switch (textFormat) {
        TextFormat.paragraph => ResponseTextFormatPB.Paragraph,
        TextFormat.bulletList => ResponseTextFormatPB.BulletedList,
        TextFormat.numberedList => ResponseTextFormatPB.NumberedList,
        TextFormat.table => ResponseTextFormatPB.Table,
        _ => null,
      },
    );
  }

  @override
  List<Object?> get props => [imageFormat, textFormat];
}

enum ImageFormat {
  text,
  image,
  textAndImage;

  bool get hasText => this == text || this == textAndImage;

  FlowySvgData get icon {
    return switch (this) {
      ImageFormat.text => FlowySvgs.ai_text_s,
      ImageFormat.image => FlowySvgs.ai_image_s,
      ImageFormat.textAndImage => FlowySvgs.ai_text_image_s,
    };
  }

  String get i18n {
    return switch (this) {
      ImageFormat.text => LocaleKeys.chat_changeFormat_textOnly.tr(),
      ImageFormat.image => LocaleKeys.chat_changeFormat_imageOnly.tr(),
      ImageFormat.textAndImage =>
        LocaleKeys.chat_changeFormat_textAndImage.tr(),
    };
  }
}

enum TextFormat {
  paragraph,
  bulletList,
  numberedList,
  table;

  FlowySvgData get icon {
    return switch (this) {
      TextFormat.paragraph => FlowySvgs.ai_paragraph_s,
      TextFormat.bulletList => FlowySvgs.ai_list_s,
      TextFormat.numberedList => FlowySvgs.ai_number_list_s,
      TextFormat.table => FlowySvgs.ai_table_s,
    };
  }

  String get i18n {
    return switch (this) {
      TextFormat.paragraph => LocaleKeys.chat_changeFormat_text.tr(),
      TextFormat.bulletList => LocaleKeys.chat_changeFormat_bullet.tr(),
      TextFormat.numberedList => LocaleKeys.chat_changeFormat_number.tr(),
      TextFormat.table => LocaleKeys.chat_changeFormat_table.tr(),
    };
  }
}

enum AiPromptCategory {
  @JsonValue("other")
  other,
  @JsonValue("development")
  development,
  @JsonValue("writing")
  writing,
  @JsonValue("healthAndFitness")
  healthAndFitness,
  @JsonValue("business")
  business,
  @JsonValue("marketing")
  marketing,
  @JsonValue("travel")
  travel,
  @JsonValue("contentSeo")
  contentSeo,
  @JsonValue("emailMarketing")
  emailMarketing,
  @JsonValue("paidAds")
  paidAds,
  @JsonValue("prCommunication")
  prCommunication,
  @JsonValue("recruiting")
  recruiting,
  @JsonValue("sales")
  sales,
  @JsonValue("socialMedia")
  socialMedia,
  @JsonValue("strategy")
  strategy,
  @JsonValue("caseStudies")
  caseStudies,
  @JsonValue("salesCopy")
  salesCopy,
  @JsonValue("education")
  education,
  @JsonValue("work")
  work,
  @JsonValue("podcastProduction")
  podcastProduction,
  @JsonValue("copyWriting")
  copyWriting,
  @JsonValue("customerSuccess")
  customerSuccess;

  String get i18n {
    return switch (this) {
      other => LocaleKeys.ai_customPrompt_others.tr(),
      development => LocaleKeys.ai_customPrompt_development.tr(),
      writing => LocaleKeys.ai_customPrompt_writing.tr(),
      healthAndFitness => LocaleKeys.ai_customPrompt_healthAndFitness.tr(),
      business => LocaleKeys.ai_customPrompt_business.tr(),
      marketing => LocaleKeys.ai_customPrompt_marketing.tr(),
      travel => LocaleKeys.ai_customPrompt_travel.tr(),
      contentSeo => LocaleKeys.ai_customPrompt_contentSeo.tr(),
      emailMarketing => LocaleKeys.ai_customPrompt_emailMarketing.tr(),
      paidAds => LocaleKeys.ai_customPrompt_paidAds.tr(),
      prCommunication => LocaleKeys.ai_customPrompt_prCommunication.tr(),
      recruiting => LocaleKeys.ai_customPrompt_recruiting.tr(),
      sales => LocaleKeys.ai_customPrompt_sales.tr(),
      socialMedia => LocaleKeys.ai_customPrompt_socialMedia.tr(),
      strategy => LocaleKeys.ai_customPrompt_strategy.tr(),
      caseStudies => LocaleKeys.ai_customPrompt_caseStudies.tr(),
      salesCopy => LocaleKeys.ai_customPrompt_salesCopy.tr(),
      education => LocaleKeys.ai_customPrompt_education.tr(),
      work => LocaleKeys.ai_customPrompt_work.tr(),
      podcastProduction => LocaleKeys.ai_customPrompt_podcastProduction.tr(),
      copyWriting => LocaleKeys.ai_customPrompt_copyWriting.tr(),
      customerSuccess => LocaleKeys.ai_customPrompt_customerSuccess.tr(),
    };
  }
}

@JsonSerializable()
class AiPrompt extends Equatable {
  const AiPrompt({
    required this.id,
    required this.name,
    required this.content,
    required this.category,
    required this.example,
    required this.isFeatured,
    required this.isCustom,
  });

  factory AiPrompt.fromPB(CustomPromptPB pb) {
    return AiPrompt(
      id: pb.id,
      name: pb.name,
      content: pb.content,
      category: AiPromptCategory.values.firstWhere(
        (e) => e.name == pb.category,
      ),
      example: pb.example,
      isFeatured: false,
      isCustom: true,
    );
  }

  factory AiPrompt.fromJson(Map<String, dynamic> json) =>
      _$AiPromptFromJson(json);

  Map<String, dynamic> toJson() => _$AiPromptToJson(this);

  final String id;
  final String name;
  final String content;
  @JsonKey(
    unknownEnumValue: AiPromptCategory.other,
    defaultValue: AiPromptCategory.other,
  )
  final AiPromptCategory category;
  @JsonKey(defaultValue: "")
  final String example;
  @JsonKey(defaultValue: false)
  final bool isFeatured;
  @JsonKey(defaultValue: false)
  final bool isCustom;

  @override
  List<Object?> get props =>
      [id, name, content, category, example, isFeatured, isCustom];
}

class CustomPromptDatabaseConfig extends Equatable {
  const CustomPromptDatabaseConfig({
    required this.view,
    required this.titleFieldId,
    required this.contentFieldId,
    required this.exampleFieldId,
    required this.categoryFieldId,
  });

  factory CustomPromptDatabaseConfig.fromAiPB(
    CustomPromptDatabaseConfigurationPB pb,
    ViewPB view,
  ) {
    final config = CustomPromptDatabaseConfig(
      view: view,
      titleFieldId: pb.titleFieldId,
      contentFieldId: pb.contentFieldId,
      exampleFieldId: pb.hasExampleFieldId() ? pb.exampleFieldId : null,
      categoryFieldId: pb.hasCategoryFieldId() ? pb.categoryFieldId : null,
    );

    return config;
  }

  factory CustomPromptDatabaseConfig.fromDbPB(
    CustomPromptDatabaseConfigPB pb,
    ViewPB view,
  ) {
    final config = CustomPromptDatabaseConfig(
      view: view,
      titleFieldId: pb.titleFieldId,
      contentFieldId: pb.contentFieldId,
      exampleFieldId: pb.hasExampleFieldId() ? pb.exampleFieldId : null,
      categoryFieldId: pb.hasCategoryFieldId() ? pb.categoryFieldId : null,
    );

    return config;
  }

  final ViewPB view;
  final String titleFieldId;
  final String contentFieldId;
  final String? exampleFieldId;
  final String? categoryFieldId;

  @override
  List<Object?> get props =>
      [view.id, titleFieldId, contentFieldId, exampleFieldId, categoryFieldId];

  CustomPromptDatabaseConfig copyWith({
    ViewPB? view,
    String? titleFieldId,
    String? contentFieldId,
    String? exampleFieldId,
    String? categoryFieldId,
  }) {
    return CustomPromptDatabaseConfig(
      view: view ?? this.view,
      titleFieldId: titleFieldId ?? this.titleFieldId,
      contentFieldId: contentFieldId ?? this.contentFieldId,
      exampleFieldId: exampleFieldId ?? this.exampleFieldId,
      categoryFieldId: categoryFieldId ?? this.categoryFieldId,
    );
  }

  CustomPromptDatabaseConfigurationPB toAiPB() {
    final payload = CustomPromptDatabaseConfigurationPB.create()
      ..viewId = view.id
      ..titleFieldId = titleFieldId
      ..contentFieldId = contentFieldId;

    if (exampleFieldId != null) {
      payload.exampleFieldId = exampleFieldId!;
    }
    if (categoryFieldId != null) {
      payload.categoryFieldId = categoryFieldId!;
    }

    return payload;
  }

  CustomPromptDatabaseConfigPB toDbPB() {
    final payload = CustomPromptDatabaseConfigPB.create()
      ..viewId = view.id
      ..titleFieldId = titleFieldId
      ..contentFieldId = contentFieldId;

    if (exampleFieldId != null) {
      payload.exampleFieldId = exampleFieldId!;
    }
    if (categoryFieldId != null) {
      payload.categoryFieldId = categoryFieldId!;
    }

    return payload;
  }
}
